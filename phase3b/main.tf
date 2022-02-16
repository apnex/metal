## additional locals
locals {}

## obtain resource pool
data "vsphere_datacenter" "datacenter" {
	name = "core"
}
data "vsphere_compute_cluster" "cluster" {
	name		= "core"
	datacenter_id	= data.vsphere_datacenter.datacenter.id
}

# create controller vm
module "controller" {
	source = "./modules/controller"

	## deployment
	name		= "router"
	datacenter	= "core"
	resource_pool	= data.vsphere_compute_cluster.cluster.resource_pool_id
	datastore	= "datastore1"
	private_key	= "router.key"
	public_key	= "router.key.pub"

	## networks / ips
	primary_nic	= { # eth0
		network		= "external"
		ip		= local.controller_ip
		netmask		= local.controller_netmask
		gateway		= local.controller_gateway
		dns		= local.controller_dns
	}
	additional_nics	= [
		{
			name	= "eth1"
			network	= "pg-mgmt"
			ip	= "172.20.10.1/24"
		},
		{
			name	= "eth2"
			network = "pg-node"
			ip	= "172.20.11.1/24"
		}
	]
}
