## controller outputs
output "vpn_endpoint" {
	value = "${local.master_ip}:1194"
}
output "vpn_client_config" {
	value = module.vpn-user-1.vpn_client_config
}
