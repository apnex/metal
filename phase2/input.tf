terraform {
	backend "local" {
		path = "./terraform.tfstate"
	}
}

## remote state - phase0
data "terraform_remote_state" "phase0" {
	backend = "local"
	config = {
		path = "../phase0/terraform.tfstate"
	}
}

## remote state - phase1
data "terraform_remote_state" "phase1" {
	backend = "local"
	config = {
		path = "../phase1/terraform.tfstate"
	}
}

variable "vcenter_url" {
	default		= "http://iso.apnex.io/VMware-VCSA-all-7.0.3-18778458.iso"
}

locals {
	esx	= {
		hostname		: data.terraform_remote_state.phase0.outputs.host_mgmt_ip
		username		: "root"
		password		: data.terraform_remote_state.phase0.outputs.root_password
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
			ip		: data.terraform_remote_state.phase0.outputs.vcenter_ip,
			prefix		: tostring(data.terraform_remote_state.phase0.outputs.public_prefix),
			gateway		: data.terraform_remote_state.phase0.outputs.public_gateway,
			dns_servers	: [
				data.terraform_remote_state.phase1.outputs.dns-service-ip
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
