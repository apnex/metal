locals {
	vcsa_url	= var.vcsa_url
	vcsa_json	= "${path.root}/state/vcsa.json"
}

# render vcsa.json
resource "local_file" "vcsa_json" {
	filename = local.vcsa_json
	content = templatefile("./tpl/vcsa.json.tpl", {
		network		= local.esx.deployment_network
		name		= local.vcsa.appliance.name
		os_password	= local.vcsa.os.password
		ip		= local.vcsa.network.ip
		prefix		= local.vcsa.network.prefix
		gateway		= local.vcsa.network.gateway
		sso_password	= local.vcsa.sso.password
		sso_domain_name	= local.vcsa.sso.domain_name
		dns_servers	= local.vcsa.network.dns_servers[0]
		ntp_servers	= local.vcsa.os.ntp_servers
	})
}

# connect to controller and stream/configure vcsa
resource "null_resource" "vcenter-appliance" {
	triggers = {
		conn_host	= local.phase1.controller_ip
		conn_type	= "ssh"
		conn_user	= "root"
		conn_key	= "../phase1/${local.phase1.controller_ssh_key}"
		vcsa_url	= local.vcsa_url
		vcsa_name	= local.vcsa.appliance.name
		vcsa_ip		= local.vcsa.network.ip
		vcsa_username	= "root"
		vcsa_password	= local.vcsa.sso.password
		vcsa_json	= abspath(local.vcsa_json)
		govc_url	= local.esx.hostname
		govc_username	= local.esx.username
		govc_password	= local.esx.password
		govc_insecure	= "true"
	}
	connection {
		host		= self.triggers.conn_host
		type		= self.triggers.conn_type
		user		= self.triggers.conn_user
		private_key     = file(self.triggers.conn_key)
	}
	provisioner "file" {
		source		= self.triggers.vcsa_json
		destination	= "/root/vcsa.json"
	}
	provisioner "file" {
		content		= templatefile("./tpl/vcsa-deploy.sh.tpl", {
			VCSA_URL	= self.triggers.vcsa_url
			VCSA_NAME	= self.triggers.vcsa_name
			VCSA_IP		= self.triggers.vcsa_ip
			VCSA_USERNAME	= self.triggers.vcsa_username
			VCSA_PASSWORD	= self.triggers.vcsa_password
			VCSA_JSON	= "/root/vcsa.json"
			GOVC_URL	= self.triggers.govc_url
			GOVC_USERNAME	= self.triggers.govc_username
			GOVC_PASSWORD	= self.triggers.govc_password
			GOVC_INSECURE	= self.triggers.govc_insecure
		})
		destination	= "/root/vcsa-deploy.sh"
	}
	provisioner "file" {
		content		= templatefile("./tpl/vcsa-remove.sh.tpl", {
			VCSA_NAME	= self.triggers.vcsa_name
			GOVC_URL	= self.triggers.govc_url
			GOVC_USERNAME	= self.triggers.govc_username
			GOVC_PASSWORD	= self.triggers.govc_password
			GOVC_INSECURE	= self.triggers.govc_insecure
		})
		destination	= "/root/vcsa-remove.sh"
	}
	provisioner "remote-exec" {
		inline	= [<<-EOT
			chmod +x ./vcsa-deploy.sh
			./vcsa-deploy.sh
		EOT
		]
	}
	provisioner "remote-exec" {
		when	= destroy
		inline	= [<<-EOT
			chmod +x ./vcsa-remove.sh
			./vcsa-remove.sh
		EOT
		]
	}
}
