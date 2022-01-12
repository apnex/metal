# Outputs
output "hostname" {
	value = metal_device.esx.hostname
}
output "host_internal_ip" {
	value = metal_device.esx.access_private_ipv4
}
output "host_mgmt_ip" {
	value = metal_device.esx.access_public_ipv4
}
output "root_password" {
	value = nonsensitive(metal_device.esx.root_password)
}

# Network
output "public_netmask" {
	value = metal_reserved_ip_block.external.netmask
}
output "public_gateway" {
	value = cidrhost(metal_reserved_ip_block.external.cidr_notation, 1)
}
output "public_first_ip" {
	value = cidrhost(metal_reserved_ip_block.external.cidr_notation, 2)
}
output "ip_vcenter" {
	value = cidrhost(metal_reserved_ip_block.external.cidr_notation, 3)
}
