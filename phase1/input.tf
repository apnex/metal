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
variable "vcenter_ip"	{ default = null }

## input locals
locals {
	network			= data.terraform_remote_state.phase0.outputs.network
	esx			= data.terraform_remote_state.phase0.outputs.esx
	controller_ip		= local.network.allocation.controller
	controller_netmask	= local.network.netmask
	controller_gateway	= local.network.gateway
	controller_dns		= local.network.dns
	vcenter_ip		= coalesce(var.vcenter_ip, local.network.allocation.vcenter)
}

## providers
provider "vsphere" {
	vsphere_server		= local.esx.address
	user			= local.esx.username
	password		= local.esx.password
	allow_unverified_ssl	= true
}
