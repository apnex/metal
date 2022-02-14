## controller outputs
output "controller_ip" {
	value = module.controller.ip
}
output "controller_ssh_key" {
	value = module.controller.ssh_key
}
output "dns_service_ip" {
	value = module.dns-service.service-ip
}
output "dns_test_cmd" {
	value = "dig @${module.controller.ip} vcenter.lab01.metal"
}
output "ssh_cmd" {
	value = "ssh -o StrictHostKeyChecking=no -i ${module.controller.ssh_key} root@${module.controller.ip}"
}
