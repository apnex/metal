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

resource "null_resource" "vcsa-deploy" {
	triggers = {
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
	provisioner "local-exec" {
		interpreter	= ["/bin/bash", "-c"]
		environment	= {
			VCSA_URL	= self.triggers.vcsa_url
			VCSA_NAME	= self.triggers.vcsa_name
			VCSA_IP		= self.triggers.vcsa_ip
			VCSA_USERNAME	= self.triggers.vcsa_username
			VCSA_PASSWORD	= self.triggers.vcsa_password
			VCSA_JSON	= self.triggers.vcsa_json
			GOVC_URL	= self.triggers.govc_url
			GOVC_USERNAME	= self.triggers.govc_username
			GOVC_PASSWORD	= self.triggers.govc_password
			GOVC_INSECURE	= self.triggers.govc_insecure
		}
		command		= "${path.root}/vcsa-deploy.sh"
	}
	depends_on = [
		local_file.vcsa_json
	]
}
