## obtain default local ESX ids
data "vsphere_datacenter" "datacenter" {}
data "vsphere_resource_pool" "pool" {}
data "vsphere_host" "esx" {
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

## create new vSwitch1
resource "vsphere_host_virtual_switch" "switch" {
	name           = "vSwitch1"
	host_system_id = data.vsphere_host.esx.id
	network_adapters = ["vmnic3"]
	active_nics  = ["vmnic3"]
	standby_nics = []
}

## create portgroup 'external'
resource "vsphere_host_port_group" "external" {
	name                = "external"
	host_system_id      = data.vsphere_host.esx.id
	virtual_switch_name = vsphere_host_virtual_switch.switch.name
}

# render ipxe script
resource "local_file" "script" {
	filename = "./state/centos.ipxe"
	content = templatefile("./tpl/centos.ipxe.tpl", {
		static_ip	= local.controller_ip
		static_netmask	= local.controller_netmask
		static_gateway	= local.controller_gateway
		static_dns	= local.controller_dns
	})
}

# create bootiso
module "bootiso" {
	source = "./modules/bootiso"
	depends_on	= [
		local_file.script
	]

	## inputs
	target_file	= "boot.iso"
	target_path	= "./state"
	script_file	= "centos.ipxe"
	script_path	= "./state"
}

# create controller vm
module "controller" {
	source = "./modules/controller"
	depends_on = [
		vsphere_host_port_group.external,
		module.bootiso
	]

	## inputs
	name		= "router"
	datacenter	= data.vsphere_datacenter.datacenter.id
	resource_pool	= data.vsphere_resource_pool.pool.id
	datastore	= "datastore1"
	network		= "external"
	bootfile_path	= "./state/boot.iso"
	bootfile_name	= "labops.centos.stage2.iso"
	private_key	= "controller.key"
	public_key	= "controller.key.pub"
}
