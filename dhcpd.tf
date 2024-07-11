resource "harvester_virtualmachine" "dhcpd" {
  name      = "dhcpd"
  namespace = "default"

  description = "dhcpd"
  tags = {
    ssh-user = "sles"
  }

  cpu    = 2
  memory = "2Gi"

  hostname     = "dhcpd"

  network_interface {
    name         = "nic-mgmt"
    model        = "virtio"
    network_name = var.equinix_public_ipv4_subnet != "" ? "${harvester_network.public_vlan[0].namespace}/${harvester_network.public_vlan[0].name}" : ""
  }

  network_interface {
    name         = "nic-vlan-1"
    model        = "virtio"
    network_name = "${harvester_network.vlans[0].namespace}/${harvester_network.vlans[0].name}"
  } 

  disk {
    name       = "disk-0"
    type       = "disk"
    size       = "10Gi"
    bus        = "virtio"
    boot_order = 1

    image       = harvester_image.sles15sp5-default.id
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name    = harvester_cloudinit_secret.cloud-config-dhcpd.name
    network_data_secret_name = harvester_cloudinit_secret.cloud-config-dhcpd.name
  }

}

resource "harvester_cloudinit_secret" "cloud-config-dhcpd" {
  name      = "cloud-config-dhcpd"
  namespace = "default"

  user_data    = templatefile("${path.module}/files/user_data.tpl", {
    dhcpd_conf_b64 = base64encode(templatefile("${path.module}/files/dhcpd.conf.tpl", {
      vm_subnet = split("/", var.equinix_private_ipv4_subnets[0])[0]
      vm_netmask = cidrnetmask(var.equinix_private_ipv4_subnets[0])
      vm_ip_range_min = cidrhost(var.equinix_private_ipv4_subnets[0], 6)
      vm_ip_range_max = cidrhost(var.equinix_private_ipv4_subnets[0], 50)
      dhcpd_address = cidrhost(var.equinix_private_ipv4_subnets[0], 5)
    }))
    additional_runcmd_data = var.additional_runcmd_data == "" ? "" : <<EOF
${var.additional_runcmd_data}
  - tailscale up --authkey ${var.tailscale_authkey} --accept-routes --advertise-routes ${var.equinix_private_ipv4_subnets[0]}
EOF
    ssh_keys = [ harvester_ssh_key.capi_ssh_key.public_key ]
  }) 
  network_data = templatefile("${path.module}/files/network_data.tpl", {
    vm_private_ip = cidrhost(var.equinix_private_ipv4_subnets[0], 5)
    vm_subnet_cidr = split("/", var.equinix_private_ipv4_subnets[0])[1]
    vm_gateway = cidrhost(var.equinix_private_ipv4_subnets[0], 1) != "" ? cidrhost(var.equinix_private_ipv4_subnets[0], 1) : "{}"
    if1_conf = local.public_vlan_static_conf
  })
}

locals {
  public_vlan_static_conf = var.equinix_public_ipv4_subnet == "" ? "dhcp4: true" :<<EOF
    dhcp4: false
    addresses:
    -  ${cidrhost(var.equinix_public_ipv4_subnet, 5)}/${split("/", var.equinix_public_ipv4_subnet)[1]} 
    gateway4: ${cidrhost(var.equinix_public_ipv4_subnet, 1)}
  EOF
}

resource "time_sleep" "wait_after_dhcpd" {
  depends_on = [
    harvester_virtualmachine.dhcpd
  ]
  create_duration = "60s"
  
}

resource "null_resource" "wicked_ifup" {
  
  count = length(var.node_ips)

  depends_on = [ time_sleep.wait_after_dhcpd ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user = "rancher"
      private_key = file("/home/mohamed/.ssh/id_rsa")
      host = var.node_ips[count.index]

    }

    inline = [
      for vlan in var.vlan_ids : "sudo ip l add link mgmt-br name mgmt.${vlan} type vlan id ${vlan} && sudo ip a add ${cidrhost(var.equinix_private_ipv4_subnets[0], 2+count.index )}/${cidrnetmask(var.equinix_private_ipv4_subnets[0])} dev mgmt.${vlan} && sudo ip l set dev mgmt.${vlan} up"
    ]
  }
  
}