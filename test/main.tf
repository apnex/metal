terraform {
	backend "local" {
		path = "./terraform.tfstate"
	}
}

## remote state - phase0
data "terraform_remote_state" "phase0" {
	backend = "local"
	config = {
		path = "../phase0/state/terraform.tfstate"
	}
}

## remote state - phase1
data "terraform_remote_state" "phase1" {
	backend = "local"
	config = {
		path = "../phase1/state/terraform.tfstate"
	}
}

variable "vcenter_url" {
	default		= "http://iso.apnex.io/VMware-VCSA-all-7.0.3-18778458.iso"
}

locals {
	phase0	= data.terraform_remote_state.phase0.outputs
	phase1	= data.terraform_remote_state.phase1.outputs
	esx	= {
		hostname		: local.phase0.esx.address
		username		: local.phase0.esx.username
		password		: local.phase0.esx.password
		deployment_network	: "external"
		datastore		: "datastore1"		
	}
	vcsa = {
		appliance: {
			thin_disk_mode		: true,
			deployment_option	: "tiny",
			name			: "vcenter.lab01.metal"
		},
		network: {
			ip_family	: "ipv4",
			mode		: "static",
			ip		: local.phase0.network.allocation.vcenter,
			prefix		: tostring(local.phase0.network.prefix),
			gateway		: local.phase0.network.gateway,
			dns_servers	: [
				local.phase1.dns-service-ip
			],
			system_name	: "vcenter.lab01.metal"
		},
		os: {
			password	: "VMware1!SDDC",
			ntp_servers	: "time.google.com",
			ssh_enable	: true
		},
		sso: {
			password	: "VMware1!SDDC",
			domain_name	: "vsphere.local"
		}
	}
}

### TESTING
resource "null_resource" "scripts" {
	triggers = {
		ip	= local.phase1.controller_ip
		ssh_key	= "../phase1/${local.phase1.controller_ssh_key}"
	}
	connection {
		host		= self.triggers.ip
		type		= "ssh"
		user		= "root"
		private_key     = file(self.triggers.ssh_key)
	}
	provisioner "remote-exec" {
		inline	= [<<-EOT
			curl -fsSL https://raw.githubusercontent.com/apnex/terraform/master/install.sh | sh
			yum -y install git
			git clone https://apnex.io/metal
		EOT
		]
	}
	provisioner "file" {
		source      = "../phase0/terraform.tfvars"
		destination = "/root/metal/phase0/terraform.tfvars"
	}
	provisioner "file" {
		source      = "../phase0/state/"
		destination = "/root/metal/phase0/state/"
	}
	provisioner "file" {
		source      = "../phase1/state/"
		destination = "/root/metal/phase1/state/"
	}
}
