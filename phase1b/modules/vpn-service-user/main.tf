# vpn-service-user
resource "null_resource" "vpn-service-user" {
	triggers = {
		master_ip	= var.master_ip
		master_ssh_key	= var.master_ssh_key
		username	= var.username
		filepath	= "${path.root}/state/${var.username}.ovpn"
	}
	connection {
		host		= self.triggers.master_ip
		type		= "ssh"
		user		= "root"
		private_key     = file(self.triggers.master_ssh_key)
	}
	provisioner "remote-exec" {
		script = "${path.module}/vpn-user.create.sh"
	}
	provisioner "local-exec" {
		command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${self.triggers.master_ssh_key} root@${self.triggers.master_ip}:~/user1.ovpn ${self.triggers.filepath}"
	}
	provisioner "local-exec" {
		when = destroy
		command	= <<-EOT
			rm ${self.triggers.filepath}
		EOT
	}
}
