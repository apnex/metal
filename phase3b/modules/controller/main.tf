# locals
locals {
	lab			= "lab01"
	bootfile_name		= "${local.lab}-${var.bootfile_name}"
	bootfile_path		= "${path.root}/state/boot.iso"
	private_key		= join("/", [path.root, "state/${local.lab}-${var.private_key}"])
	public_key		= "${local.private_key}.pub"
	network_list		= {for item in var.additional_nics: item.network => item}
	controller_network	= var.primary_nic.network
	controller_ip		= var.primary_nic.ip
	controller_netmask	= var.primary_nic.netmask
	controller_gateway	= var.primary_nic.gateway
	controller_dns		= var.primary_nic.dns
}

# data sources
data "vsphere_datacenter" "datacenter" {
	name		= var.datacenter
}
data "vsphere_datastore" "datastore" {
	name		= var.datastore
	datacenter_id	= data.vsphere_datacenter.datacenter.id
}
data "vsphere_network" "primary" {
	name		= local.controller_network
	datacenter_id	= data.vsphere_datacenter.datacenter.id
}
data "vsphere_network" "additional" {
	for_each	= local.network_list
	name		= each.value.network
	datacenter_id	= data.vsphere_datacenter.datacenter.id
}

# generate local sshkey
resource "null_resource" "generate-sshkey" {
	triggers = {
		ssh_key	= local.private_key
	}
	provisioner "local-exec" {
		command = <<-EOT
			yes y | ssh-keygen -b 4096 -t rsa -C 'root' -N '' -f "${self.triggers.ssh_key}"
		EOT
	}
	provisioner "local-exec" {
		when = destroy
		command = <<-EOT
			rm "${self.triggers.ssh_key}"
			rm "${self.triggers.ssh_key}.pub"
		EOT
	}
}

# render ipxe script
resource "local_file" "script" {
	filename = "${path.root}/state/centos.ipxe"
	content = templatefile("${path.root}/tpl/centos.ipxe.tpl", {
		static_ip	= local.controller_ip
		static_netmask	= local.controller_netmask
		static_gateway	= local.controller_gateway
		static_dns	= local.controller_dns
	})
}

# create bootiso
module "bootiso" {
	source = "../bootiso"
	depends_on	= [
		local_file.script
	]

	## inputs
	target_file	= "boot.iso"
	target_path	= "${path.root}/state"
	script_file	= "centos.ipxe"
	script_path	= "${path.root}/state"
}

# upload file to datastore
resource "vsphere_file" "push-file" {
	depends_on	= [
		module.bootiso
	]
	datacenter		= var.datacenter
	datastore		= var.datastore
	source_file		= local.bootfile_path
	destination_file	= "iso/${local.bootfile_name}"
}

# create VM
resource "vsphere_virtual_machine" "controller" {
	name				= var.name
	resource_pool_id		= var.resource_pool
	datastore_id			= data.vsphere_datastore.datastore.id
	wait_for_guest_net_timeout	= 40 # minutes
	depends_on = [
		vsphere_file.push-file,
		null_resource.generate-sshkey
	]
	lifecycle {
		ignore_changes = [
			cdrom,
			disk
		]
	}

	# copy public key to vm
	provisioner "file" {
		source      = local.public_key
		destination = "/tmp/authorized_keys"
		connection {
			host		= self.default_ip_address
			type		= "ssh"
			user		= "root"
			password	= "VMware1!"
		}
	}
	# enable authorized_keys
	provisioner "remote-exec" {
		inline = [<<-EOT
			echo "Creating authorized_keys.. "
			mkdir -p /root/.ssh/
			chmod 700 /root/.ssh
			mv /tmp/authorized_keys /root/.ssh/authorized_keys
			chmod 600 /root/.ssh/authorized_keys
		EOT
		]
		connection {
			host		= self.default_ip_address
			type		= "ssh"
			user		= "root"
			password	= "VMware1!"
		}
	}
	provisioner "remote-exec" {
		inline = [<<-EOT
			while [ ! -f /root/startup.done ]; do
				sleep 10;
				echo "Waiting for runonce startup scripts.. "
			done
			hostnamectl set-hostname ${self.name}
			docker version
			docker ps
		EOT
		]
		connection {
			host		= self.default_ip_address
			type		= "ssh"
			user		= "root"
			private_key     = file(local.private_key)
		}
	}

	# resources
	guest_id			= "centos7_64Guest"
	nested_hv_enabled		= true
	num_cores_per_socket		= 4
	num_cpus			= 4
	memory				= 4096

	# hardware
	cdrom {
		datastore_id		= data.vsphere_datastore.datastore.id
		path			= "iso/${local.bootfile_name}"
	}
	disk {
		label			= "disk0"
		unit_number		= 0 
		thin_provisioned	= true
		size			= 32
	}
	network_interface {
		network_id = data.vsphere_network.primary.id
	}
	dynamic "network_interface" {
		for_each = local.network_list
		iterator = item
		content {
			network_id = data.vsphere_network.additional[item.key].id
		}
	}
}

## create render from template file
resource "null_resource" "network_config" {
	triggers	= {
		always_run		= timestamp()
		controller_ip		= vsphere_virtual_machine.controller.default_ip_address
		controller_ssh_key	= local.private_key
	}
	connection {
		host		= self.triggers.controller_ip
		type		= "ssh"
		user		= "root"
		private_key     = file(self.triggers.controller_ssh_key)
	}
	provisioner "file" {
		content = templatefile("${path.module}/network-config.sh.tpl", {
			nics = var.additional_nics
		})
		destination = "/root/network-config.sh"
	}
	provisioner "remote-exec" {
		inline	= [<<-EOT
			chmod +x /root/network-config.sh
			/root/network-config.sh
		EOT
		]
	}
}
