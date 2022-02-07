## additional locals
locals {
	master_ip	= local.phase1.controller_ip
	master_key	= "../phase1/${local.phase1.controller_ssh_key}"
}

# render dns service yaml
resource "local_file" "vpn-service-yaml" {
	filename = "./state/vpn-service.yaml"
	content = templatefile("./tpl/vpn-service.yaml.tpl", {
		VPN_ENDPOINT = local.master_ip
	})
}

# install vpn-service to controller
module "vpn-service" {
	source			= "./modules/vpn-service"
	master_ip		= local.master_ip
	master_ssh_key		= local.master_key
	manifest		= "vpn-service.yaml"
	depends_on = [
		local_file.vpn-service-yaml
	]
}

# create vpn-service-user
module "vpn-user-1" {
	source			= "./modules/vpn-service-user"
	master_ip		= local.master_ip
	master_ssh_key		= local.master_key
	username		= "user1"
	depends_on = [
		module.vpn-service
	]
}
