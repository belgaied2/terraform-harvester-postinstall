ping-check on;
ddns-update-style none;
authoritative;

option domain-name "suse";
option domain-name-servers 8.8.8.8;
default-lease-time 86400;
max-lease-time 86400;
option subnet-mask 255.255.255.0;
local-address ${dhcpd_address};

subnet 10.0.2.0 netmask 255.255.255.0 {}

subnet ${vm_subnet} netmask ${vm_netmask} {
  range ${vm_ip_range_min} ${vm_ip_range_max};
  option routers ${dhcpd_address};
}

