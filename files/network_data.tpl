version: 2
ethernets:
  eth0:
${if1_conf}
  eth1:
    dhcp4: false
    addresses:
      - ${vm_private_ip}/${vm_subnet_cidr}
#    gateway4: ${vm_gateway}
  
