## controller outputs
output "controller_ip" {
	value = module.controller.ip
}
output "controller_ssh_key" {
	value = module.controller.ssh_key
}
output "dns-service-ip" {
	value = module.dns-service.service-ip
}
output "ssh_string" {
	value = "ssh -o StrictHostKeyChecking=no -i ${module.controller.ssh_key} root@${module.controller.ip}"
}
