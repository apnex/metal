terraform {
	required_providers {
		metal = {
			source = "equinix/metal"
		}
	}
}

## define variables
variable "auth_token"	{}

## input locals
locals {
	auth_token = var.auth_token
}

## providers
provider "metal" {
	auth_token = local.auth_token
}
