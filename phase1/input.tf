terraform {
	backend "local" {
		path = "./terraform.tfstate"
	}
	required_providers {
		vsphere = ">= 1.15.0"
	}
}

## remote state
data "terraform_remote_state" "phase0" {
	backend = "local"
	config = {
		path = "../phase0/terraform.tfstate"
	}
}

## define variables
variable "esx_ip"	{ default = null }
variable "esx_user"	{ default = null }
variable "esx_pass"	{ default = null }

## input locals
locals {
	esx_ip			= coalesce(var.esx_ip, data.terraform_remote_state.phase0.outputs.host_mgmt_ip)
	esx_user		= coalesce(var.esx_user, "root")
	esx_pass		= coalesce(var.esx_pass, data.terraform_remote_state.phase0.outputs.root_password)
	controller_ip		= data.terraform_remote_state.phase0.outputs.public_first_ip
	controller_netmask	= data.terraform_remote_state.phase0.outputs.public_netmask
	controller_gateway	= data.terraform_remote_state.phase0.outputs.public_gateway
	controller_dns		= "8.8.8.8"
}

## providers
provider "vsphere" {
	vsphere_server		= local.esx_ip
	user			= local.esx_user
	password		= local.esx_pass
	allow_unverified_ssl	= true
}
