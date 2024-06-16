#cloud-config
user: sles
password: suse1234
chpasswd:
  expire: false
ssh_pwauth: true
ssh_authorized_keys:
%{ for ssh_key in ssh_keys ~}
  - ${ssh_key}
%{ endfor ~}
package_update: false
write_files:
- content: |
    [Unit]
    Description=Enable NAT
    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
    [Install]
    WantedBy=multi-user.target
  path: /etc/systemd/system/iptables.service
- content: |
    net.ipv4.ip_forward = 1
    net.ipv6.conf.all.disable_ipv6 = 1
  path: /etc/sysctl.d/99-sysctl.conf
  owner: root:root
  permissions: '0644'
- encoding: b64
  content: ${dhcpd_conf_b64}
  owner: root:root
  path: /etc/dhcpd.conf
  permissions: '0644'
runcmd:
  - echo nameserver 1.1.1.1 >> /etc/resolv.conf 
  - echo nameserver 8.8.8.8 >> /etc/resolv.conf 
  - - systemctl
    - enable
    - '--now'
    - qemu-guest-agent
  - sed -i 's/^DHCPD_INTERFACE=.*/DHCPD_INTERFACE="eth1"/g' /etc/sysconfig/dhcpd
  - - systemctl
    - enable
    - '--now'
    - dhcpd
  - iptables -A INPUT -i eth0 -p udp --destination-port 67 -j DROP
  - iptables-save
  - systemctl daemon-reload
  - systemctl enable --now iptables.service
  - sysctl -p /etc/sysctl.d/99-sysctl.conf
  - systemctl daemon-reload
  - systemctl enable --now container-registry.service
  - curl -sL https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.7.3/clusterctl-linux-amd64 -o /usr/local/bin/clusterctl
  - chmod 0755 /usr/local/bin/clusterctl
  - curl -sL https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
  - chmod 0755 /usr/local/bin/kubectl
${additional_runcmd_data}
