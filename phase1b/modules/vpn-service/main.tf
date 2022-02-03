# vpn-service
resource "null_resource" "vpn-service" {
	triggers = {
		master_ip	= var.master_ip
		master_ssh_key	= var.master_ssh_key
		manifest_src	= "${path.root}/state/${var.manifest}"
		manifest_dst	= "/root/${var.manifest}"
	}
	connection {
		host		= self.triggers.master_ip
		type		= "ssh"
		user		= "root"
		private_key     = file(self.triggers.master_ssh_key)
	}
	provisioner "file" {
		source      = self.triggers.manifest_src
		destination = self.triggers.manifest_dst
	}
	provisioner "remote-exec" {
		inline	= [<<-EOT
			kubectl apply -f "${self.triggers.manifest_dst}"
			#while [[ $(kubectl get pods control-dns -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
			#        echo "waiting for PODS" && sleep 3;
			#done
			kubectl get pods -A
			echo "waiting for [ VPN-SERVICE ] to start"
			sleep 20
		EOT
		]
	}
	provisioner "remote-exec" {
		when = destroy
		inline	= [<<-EOT
			kubectl delete -f "${self.triggers.manifest_dst}"
		EOT
		]
	}
}
