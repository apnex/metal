output "vcsa_json" {
	value = jsondecode(file(module.vcenter.vcsa_json))
}
