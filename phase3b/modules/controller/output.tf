output "ip" {
	value = vsphere_virtual_machine.controller.default_ip_address
}

output "id" {
	value = vsphere_virtual_machine.controller.id
}

output "moid" {
	value = vsphere_virtual_machine.controller.moid
}

output "ssh_key" {
	value = local.private_key
}

output "pub_key" {
	value = local.public_key
}
