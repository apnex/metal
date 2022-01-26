output "vcsa_url" {
	value = local.vcsa_url
}

output "vcsa_json" {
	value = local.vcsa_json
}

output "vcenter_name" {
	value = local.vcsa.appliance.name
}

output "vcenter_url" {
	value = "https://${local.vcsa.appliance.name}"
}

output "vcenter_ip" {
	value = local.vcsa.network.ip
}

output "sso_username" {
	value = "administrator@${local.vcsa.sso.domain_name}"
}

output "sso_password" {
	value = local.vcsa.sso.password
}
