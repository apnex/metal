locals {
	clusters = var.clusters
	storage = "" #var.storage
	nodes = merge([
		for key,cluster in local.clusters: {
			for node in cluster.nodes: node => key
		}
	]...)
	compute_clusters = merge([
		for key,cluster in local.clusters: {
			(key) = {
				vsan = (try(local.storage[cluster.storage].cache, false) != false) ? true : false
				vcls = (try(cluster.vcls, "notexist") != "notexist") ? cluster.vcls : true
				nodes = cluster.nodes			
			}
		}
	]...)
}

# datacenter
resource "vsphere_datacenter" "datacenter" {
	name = "core"
}

# foreach host, get thumbprint
data "vsphere_host_thumbprint" "thumbprint" {
	for_each	= local.nodes
	address		= each.key
	insecure	= true
}

## foreach cluster, create cluster
resource "vsphere_compute_cluster" "clusters" {
	for_each			= local.compute_clusters
	name				= each.key
	datacenter_id			= vsphere_datacenter.datacenter.moid
	drs_enabled			= false
	drs_automation_level		= "partiallyAutomated"
	ha_enabled			= false
	host_managed			= true
}

# foreach host, join to datacenter
resource "vsphere_host" "host" {
	for_each	= local.nodes
	hostname	= each.key
	username	= local.phase0.esx.username
	password	= local.phase0.esx.password
	thumbprint	= data.vsphere_host_thumbprint.thumbprint[each.key].id
	cluster		= vsphere_compute_cluster.clusters["core"].id
}

# create switch
resource "vsphere_distributed_virtual_switch" "dvs" {
	name		= "fabric"
	version		= "7.0.0"
	datacenter_id	= vsphere_datacenter.datacenter.moid
	uplinks		= ["uplink1","uplink2"]
	active_uplinks	= ["uplink1","uplink2"]
	standby_uplinks	= []
	max_mtu		= 9000
	dynamic "host" {
		for_each = local.nodes
		content {
			host_system_id = vsphere_host.host[host.key].id
			devices        = [ "vmnic1" ]
		}
	}
}

# create portgroup pg-mgmt
resource "vsphere_distributed_port_group" "pg-mgmt" {
	name				= "pg-mgmt"
	distributed_virtual_switch_uuid	= vsphere_distributed_virtual_switch.dvs.id
	allow_forged_transmits		= true
	allow_mac_changes		= true
	allow_promiscuous		= false
	vlan_id				= 10
}

# create portgroup pg-node
resource "vsphere_distributed_port_group" "pg-node" {
	name				= "pg-node"
	distributed_virtual_switch_uuid	= vsphere_distributed_virtual_switch.dvs.id
	allow_forged_transmits		= true
	allow_mac_changes		= true
	allow_promiscuous		= false
	vlan_id				= 20
}
