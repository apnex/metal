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

resource "null_resource" "import-ova" {
	triggers = {
		always_run	= timestamp()
		vcsa_url	= local.vcsa_url
		vcsa_name	= local.vcsa.appliance.name
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
			GOVC_URL	= self.triggers.govc_url
			GOVC_USERNAME	= self.triggers.govc_username
			GOVC_PASSWORD	= self.triggers.govc_password
			GOVC_INSECURE	= self.triggers.govc_insecure
		}
		command		= <<-EOT
			## set docker cmd
			GOVC="docker run --rm -t"
			GOVC+=" -e GOVC_URL"
			GOVC+=" -e GOVC_USERNAME"
			GOVC+=" -e GOVC_PASSWORD"
			GOVC+=" -e GOVC_INSECURE"
			GOVC+=" -v $PWD/state/vcsa.json:/iso/vcsa.json"
			GOVC+=" vmware/govc /govc"
			## import
			$GOVC import.ova --options=/iso/vcsa.json $VCSA_URL
			$GOVC vm.change -vm $VCSA_NAME -g vmwarePhoton64Guest
			$GOVC vm.power -on $VCSA_NAME
		EOT
	}
	depends_on = [
		local_file.vcsa_json
	]
}
