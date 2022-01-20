terraform {
	backend "local" {
		path = "./state/terraform.tfstate"
	}
	required_providers {
		metal = {
			source = "equinix/metal"
		}
	}
}

## define variables
variable "auth_token"		{}
variable "project"		{
	default = "labops"
}
variable "metro"		{
	default = "sy"
}
variable "operating_system"	{
	default = "vmware_esxi_7_0"
}
variable "hostname"		{
	default = "core"
}
variable "plan"			{
	default = "c3.small.x86"
}

## input locals
locals {
	auth_token = var.auth_token
}

## providers
provider "metal" {
	auth_token = local.auth_token
}
