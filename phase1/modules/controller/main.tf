# locals
locals {
	lab			= "lab01"
	bootfile_name		= "${local.lab}-${var.bootfile_name}"
	bootfile_path		= var.bootfile_path
	private_key		= join("/", [abspath(path.root), "state/${local.lab}-${var.private_key}"])
	public_key		= "${local.private_key}.pub"
}

# data sources
data "vsphere_datacenter" "datacenter" {
	name			= var.datacenter
}
data "vsphere_resource_pool" "pool" {}
data "vsphere_datastore" "datastore" {
	name			= var.datastore
	datacenter_id		= data.vsphere_datacenter.datacenter.id
}
data "vsphere_network" "network" {
	name			= var.network
	datacenter_id		= data.vsphere_datacenter.datacenter.id
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

# upload file to datastore
resource "vsphere_file" "push-file" {
	datacenter		= var.datacenter
	datastore		= var.datastore
	source_file		= local.bootfile_path
	destination_file	= "iso/${local.bootfile_name}"
}

# create VM
resource "vsphere_virtual_machine" "vm" {
	name				= var.name
	resource_pool_id		= data.vsphere_resource_pool.pool.id
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
				sleep 9;
				echo "Waiting for runonce startup scripts.. "
			done
			hostnamectl set-hostname router
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
		network_id		= data.vsphere_network.network.id
	}
}
