terraform {
	backend "local" {
		path = "./state/terraform.tfstate"
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

variable "vcsa_url" {
	default	= "https://iso.apnex.io/VMware-vCenter-Server-Appliance-7.0.3.00100-18778458_OVF10.ova"
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
				local.phase1.dns_service_ip
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
