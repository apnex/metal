## copy state to controller
resource "null_resource" "scripts" {
	triggers = {
		ip	= module.controller.ip
		ssh_key	= module.controller.ssh_key
	}
	connection {
		host		= self.triggers.ip
		type		= "ssh"
		user		= "root"
		private_key     = file(self.triggers.ssh_key)
	}
	provisioner "remote-exec" {
		inline	= [<<-EOT
			curl -fsSL https://raw.githubusercontent.com/apnex/terraform/master/install.sh | sh
			yum -y install git
			git clone https://apnex.io/metal
		EOT
		]
	}
	provisioner "file" {
		source      = "../phase0/terraform.tfvars"
		destination = "/root/metal/phase0/terraform.tfvars"
	}
	provisioner "file" {
		source      = "../phase0/state/"
		destination = "/root/metal/phase0/state/"
	}
	provisioner "file" {
		source      = "../phase1/state/"
		destination = "/root/metal/phase1/state/"
	}
	depends_on = [
		 dns_a_record_set.www
	]
}

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
output "dns_test_cmd" {
	value = "dig @${module.controller.ip} vcenter.lab01.metal"
}
output "ssh_cmd" {
	value = "ssh -o StrictHostKeyChecking=no -i ${module.controller.ssh_key} root@${module.controller.ip}"
}
