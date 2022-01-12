terraform {
	backend "local" {
		path = "./terraform.tfstate"
	}
}

# phase0 state
data "terraform_remote_state" "phase0" {
	backend = "local"
	config = {
		path = "../phase0/terraform.tfstate"
	}
}

# phase1 state
data "terraform_remote_state" "phase1" {
	backend = "local"
	config = {
		path = "../phase1/terraform.tfstate"
	}
}

## define variables
variable "vcenter_ip"		{ default = null }
variable "master_ip"		{ default = null }
variable "master_ssh_key"	{ default = null }

## input locals
locals {
	vcenter_ip	= coalesce(var.vcenter_ip, data.terraform_remote_state.phase0.outputs.ip_vcenter)
	master_ip	= coalesce(var.master_ip, data.terraform_remote_state.phase1.outputs.controller_ip)
	master_ssh_key	= coalesce(var.master_ssh_key, data.terraform_remote_state.phase1.outputs.controller_ssh_key)
	dns_key		= "dnsctl."
	dns_key_secret	= "Vk13YXJlMSE="
	#echo -n 'VMware1!' | base64
}
