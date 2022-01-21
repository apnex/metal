locals {
	prefix		= "lab01"
	vcenter_url	= var.vcenter_url
	vcenter_file	= "vcenter.iso"
	vcenter_json	= "${path.root}/state/vcsa.json"
	not_dry_run	= "false"
}

## render vcsa.json
resource "local_file" "vcsa-json" {
	filename	= local.vcenter_json
	content		= jsonencode({
		"__version": "2.13.0",
		"new_vcsa": {
			"esxi": local.esx,
			"appliance": local.vcsa.appliance,
			"network": local.vcsa.network,
			"os": local.vcsa.os,
			"sso": local.vcsa.sso
		},
		"ceip": {
			"settings": {
				"ceip_enabled": false
			}
		}
	})
}

## load vcsa.json
data "local_file" "vcsa_json" {
	filename	= local.vcenter_json
	depends_on	= [
		local_file.vcsa-json
	]
}

# install vcenter
module "vcenter" {
	source		= "./modules/vcenter"
	prefix		= local.prefix
	vcenter_url	= local.vcenter_url
	vcenter_file	= local.vcenter_file
	vcenter_json	= local.vcenter_json
	not_dry_run	= local.not_dry_run
	depends_on	= [
		local_file.vcsa-json
	]
}
