#!/bin/bash -x
sed -e 's/^USE_LXC_BRIDGE="true"/USE_LXC_BRIDGE="false"/' -i /etc/default/lxc-net
service lxc-net restart

ifdown eth0
mv /etc/network/interfaces.d/eth0.cfg /etc/network/interfaces.d/eth0.cfg.bak
cat <<-"EOF" > /etc/network/interfaces.d/bridge.cfg
auto eth0
iface eth0 inet manual

auto lxcbr0
iface lxcbr0 inet dhcp
bridge_ports eth0
EOF
ifup eth0 lxcbr0
