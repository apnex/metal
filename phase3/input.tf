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

## remote state - phase2
data "terraform_remote_state" "phase2" {
	backend = "local"
	config = {
		path = "../phase2/state/terraform.tfstate"
	}
}

locals {
	phase0	= data.terraform_remote_state.phase0.outputs
	phase1	= data.terraform_remote_state.phase1.outputs
	phase2	= data.terraform_remote_state.phase2.outputs
}

provider "vsphere" {
	vsphere_server		= local.phase2.vcenter_name
	user			= local.phase2.sso_username
	password		= local.phase2.sso_password
	allow_unverified_ssl	= true
}

variable "clusters" {
	default = {
		core	= {
			storage	= "local"
			nodes	= [
				"core.lab01.metal"
			]
		}
	}
}
