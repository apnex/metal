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
			## check if deployment ready
			ALIVE=0
			DEPLOYMENT="control-vpn"
			while [[ $ALIVE == 0 ]]; do
				TEST=$(kubectl get deployments $DEPLOYMENT -o json | jq -r '.status.conditions[] | select(.reason=="MinimumReplicasAvailable") | .status')
				if [[ $TEST == "True" ]]; then
					ALIVE=1
					echo "Success: deployment [ $DEPLOYMENT ] is ALIVE!"
				else
					echo "Waiting for deployment [ $DEPLOYMENT ] to be ready"
					sleep 5;
				fi
			done
			kubectl get pods -A

			## get POD from deployment
			SELECTOR="name=control-vpn-deploy"
			POD=$(kubectl get pods --selector=$SELECTOR -o json | jq -r '.items[0] | .metadata.name')
			echo "POD [ $POD ]"

			## check if VPN service initialised
			ALIVE=0
			DEPLOYMENT="control-vpn"
			while [[ $ALIVE == 0 ]]; do
				TEST=$((kubectl exec -it $POD -- test -f /etc/openvpn/pki/ta.key 2>/dev/null) && echo 0 || echo 1)
				if [[ $TEST -eq 0 ]]; then
					ALIVE=1
					echo "Success: service [ VPN-SERVICE ] is ALIVE!"
				else
					echo "Waiting for [ VPN-SERVICE ] to start ..."
					sleep 10;
				fi
			done
			echo "Service [ VPN-SERVICE ] started"
			sleep 5
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
