# external md5
data "external" "trigger" {
	program = ["/bin/bash", "-c", <<EOF
		CHECKSUM=$(cat ${path.root}/state/${var.manifest} | md5sum | awk '{ print $1 }')
		jq -n --arg checksum "$CHECKSUM" '{"checksum":$checksum}'
	EOF
	]
}

# dns-service
resource "null_resource" "dns-service" {
	triggers = {
		#md5		= data.external.trigger.result["checksum"]
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
			while [[ $(kubectl get pods control-dns -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
			        echo "waiting for PODS" && sleep 3;
			done
			kubectl get pods -A
			echo "waiting for [ BIND ] to start"
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

# retrieve service IP
data "external" "service-ip" {
	program = ["/bin/bash", "-c", <<-EOT
		read -r -d '' COMMANDS <<-EOF
			kubectl get services -o json | jq -r '.items[] | select(.metadata.name | contains("vip-control-dns-rndc")).status.loadBalancer.ingress[0].ip'
		EOF
		VALUE=$(ssh root@${var.master_ip} -i ${var.master_ssh_key} -o LogLevel=QUIET -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t "$COMMANDS" | tr -d '\r')
		jq -n --arg value "$VALUE" '{"value":$value}'
	EOT
	]
	depends_on = [
		null_resource.dns-service
	]
}
