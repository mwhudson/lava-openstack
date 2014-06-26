#!/bin/bash -x
# This runs as root.
mkdir -p ~ubuntu/.ssh
cp id_rsa* ~ubuntu/.ssh
cat ~ubuntu/.ssh/id_rsa.pub >> ~ubuntu/.ssh/authorized_keys
cat >> ~ubuntu/.ssh/config <<EOF
StrictHostKeyChecking no
EOF
chown -R ubuntu:ubuntu ~ubuntu/.ssh
chmod 0600 ~ubuntu/.ssh/id_rsa
chmod 0644 ~ubuntu/.ssh/id_rsa.pub
chmod 0700 ~ubuntu/.ssh

lava-sync ssh-done

lava-network broadcast eth0
lava-network collect eth0

if [ $(lava-group bootstrap | awk 'END { print NR }') != 1 ]; then
    echo "There should be exactly one bootstrap node!"
    exit 1
fi

export BOOTSTRAP_IP=$(lava-network query $(lava-group bootstrap) ipv4)
export MACHINE_IPS=
for host in $(lava-group machine); do
    MACHINE_IPS="$MACHINE_IPS${MACHINE_IPS:+ }$(lava-network query $host) ipv4"
done

sudo -u ubuntu ssh ubuntu@$BOOTSTRAP_IP true
for machine_ip in $MACHINE_IPS; do
    sudo -u ubuntu ssh ubuntu@$machine_ip true
done

if [ `lava-role` = "bootstrap" ]; then
    apt-get install -y juju-core juju-deployer git testrepository subunit python-nose python-lxml python-openstackclient lxc
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
    sudo -u ubuntu PATH=$PATH ./do-packaged-stack-controller.sh
fi

if [ "$LAVA_SLEEP_FOR_ACCESS" = "yes" ]; then
    sleep 3600
fi

lava-sync all-done
