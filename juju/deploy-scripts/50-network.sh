# Set up the network by copying a script over to the cloud-controler
# node and running it there.

cat > /tmp/network-setup.sh <<EOF
#!/bin/bash -xe

# Create a small network
FIXED_RANGE=192.168.1.0/24
FIXED_NETWORK_SIZE=256
sudo nova-manage network create "private" $FIXED_RANGE 1 $FIXED_NETWORK_SIZE --bridge br100

# Create some floating ips
FLOATING_RANGE=${FLOATING_RANGE:-172.24.4.0/24}
sudo nova-manage floating create $FLOATING_RANGE
EOF
chmod u+x /tmp/network-setup.sh

juju scp /tmp/network-setup.sh nova-cloud-controller/0:
juju run --unit nova-cloud-controller/0 ./network-setup.sh
