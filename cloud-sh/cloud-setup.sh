#!/bin/sh -e

. ~/admin-openrc

# adjust tiny image
nova flavor-delete m1.tiny
nova flavor-create m1.tiny 1 512 8 1

# Create a small network
FIXED_RANGE=192.168.1.0/24
FIXED_NETWORK_SIZE=256
nova-manage network create "private" $FIXED_RANGE 1 $FIXED_NETWORK_SIZE

# Create some floating ips
FLOATING_RANGE=${FLOATING_RANGE:-172.24.4.0/24}
nova-manage floating create $FLOATING_RANGE --pool=public


# create ubuntu user
keystone tenant-create --name ubuntu --description "Created by Juju"
keystone user-create --name ubuntu --tenant ubuntu --pass password --email juju@localhost
#keystone user-role-add --user ubuntu --role _member_ --tenant ubuntu

# configure security groups
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

# import key pair
nova keypair-add --pub-key id_rsa.pub ubuntu-keypair
