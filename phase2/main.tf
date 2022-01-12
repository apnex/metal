# render dns service yaml
resource "local_file" "dns-service-yaml" {
	filename = "./state/dns-service.yaml"
	content = templatefile("./tpl/dns-service.yaml.tpl", {
		zones = [
			{
				domain	= "lab01.metal"
				name	= "lab01.metal"
				file	= "lab01.metal.zone.fwd"
			},
			{
				domain	= "lab01.metal"
				name	= "62.144.136.in-addr.arpa"
				file	= "lab01.metal.zone.rev"
			}
		]
	})
}

# install dns-service to controller
module "dns-service" {
	source			= "./modules/dns-service"
	master_ip		= local.master_ip
	master_ssh_key		= local.master_ssh_key
	manifest		= "dns-service.yaml"
	depends_on = [
		local_file.dns-service-yaml
	]
}

# nsupdate provider
provider "dns" {
	update {
		server        = local.master_ip
		key_name      = local.dns_key
		key_algorithm = "hmac-md5"
		key_secret    = local.dns_key_secret
	}
}

# create vcenter A record
resource "dns_a_record_set" "www" {
	zone = "lab01.metal."
	name = "vcenter"
	addresses = [
		local.vcenter_ip
	]
	ttl = 300
	depends_on = [
		module.dns-service
	]
}
