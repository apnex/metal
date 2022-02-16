terraform {
	backend "local" {
		path = "./state/terraform.tfstate"
	}
	required_providers {
		vsphere = ">= 1.15.0"
	}
}

## remote state
data "terraform_remote_state" "phase0" {
	backend = "local"
	config = {
		path = "../phase0/state/terraform.tfstate"
	}
}

## remote state
data "terraform_remote_state" "phase2" {
	backend = "local"
	config = {
		path = "../phase2/state/terraform.tfstate"
	}
}

## define variables
variable "vcenter_ip"	{ default = null }

## input locals
locals {
	phase0			= data.terraform_remote_state.phase0.outputs
	phase2			= data.terraform_remote_state.phase2.outputs
	network			= local.phase0.network
	controller_ip		= local.network.allocation.router
	controller_netmask	= local.network.netmask
	controller_gateway	= local.network.gateway
	controller_dns		= local.network.dns
}

## providers
provider "vsphere" {
	vsphere_server		= local.phase2.vcenter_ip
	user			= local.phase2.sso_username
	password		= local.phase2.sso_password
	allow_unverified_ssl	= true
}
