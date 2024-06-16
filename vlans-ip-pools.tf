data "harvester_clusternetwork" "mgmt" {
  name = "mgmt"
}

resource "harvester_network" "vlans" {
  count = length(var.equinix_private_ipv4_subnets)

  name      =  "vlan-${var.vlan_ids[count.index]}"
  namespace =  "harvester-public"
  vlan_id = var.vlan_ids[count.index] 
  cluster_network_name = data.harvester_clusternetwork.mgmt.name
  description = "VM Network for vlan-${var.vlan_ids[count.index]}"
  route_mode = "manual"
  route_cidr = var.equinix_private_ipv4_subnets[count.index]
  route_gateway = cidrhost(var.equinix_private_ipv4_subnets[count.index], 1)
}


resource "harvester_network" "public_vlan" {

  count = var.equinix_public_ipv4_subnet != "" ? 1 : 0

  name = "public-vlan"
  namespace = "harvester-public"
  vlan_id = 250 + var.cluster_number
  cluster_network_name = data.harvester_clusternetwork.mgmt.name
  description = "Public Network for vlan-${250 + var.cluster_number}"
  route_mode = "manual"
  route_cidr = var.equinix_public_ipv4_subnet
  route_gateway = cidrhost(var.equinix_public_ipv4_subnet, 1)
  
}

resource "kubernetes_manifest" "ip-pools" {
  count = length(var.equinix_private_ipv4_subnets)

  depends_on= [harvester_network.vlans]
  manifest = yamldecode(templatefile("${path.module}/manifests/ip-pool.yaml.tpl", {
    gateway = cidrhost(var.equinix_private_ipv4_subnets[count.index], 1)
    name = "1"
    range-start = cidrhost(var.equinix_private_ipv4_subnets[count.index], 60)
    range-end = cidrhost(var.equinix_private_ipv4_subnets[count.index], 100)
    subnet = var.equinix_private_ipv4_subnets[count.index]
    vlan = harvester_network.vlans[count.index].name
    vlan-namespace = "harvester-public"
  }))
}

# resource "null_resource" "delete_capi_clusters" {
#   triggers = {
#     harvester_router_vm = harvester_virtualmachine.dhcpd.id
#     cluster_number = var.cluster_number
#   }

#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig ../harvester-cl${self.triggers.cluster_number}-rke2.yaml delete clusters --all --all-namespaces"

#     when = destroy
    
#   }
# }