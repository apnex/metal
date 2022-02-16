terraform {
	required_providers {
		vsphere = ">= 1.15.0"
		# 1.15.0 is required to workaround the "PolicyIDByVirtualMachine" error due to missing vCenter
		# Fix due to be rolled out in v2.0.3 (~Jan 2022)
		# https://github.com/hashicorp/terraform-provider-vsphere/issues/1033
	}
}

variable "name"			{}
variable "datacenter"		{}
variable "resource_pool"	{}
variable "datastore"		{}
variable "bootfile_name"	{
	default	= "router.iso"
}
variable "private_key"		{}
variable "public_key"		{}

## testing
variable "primary_nic"		{}
variable "additional_nics"	{}
