terraform {
	backend "local" {
		path = "./state/terraform.tfstate"
	}
}

## remote state
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

## input locals
locals {
	phase0	= data.terraform_remote_state.phase0.outputs
	phase1	= data.terraform_remote_state.phase1.outputs
}
