#!/bin/bash -x
mydir=$(readlink -f $0)
git clone https://github.com/openstack/tempest.git ~/tempest
IMAGE_UUID=`glance image-list | awk '/linaro.*ami/{print $2}'`
. cloud/ubuntu-openrc
access=$(keystone ec2-credentials-create | grep access | awk '{ print $4 }')
secret=$(keystone ec2-credentials-get --access $access | grep secret | awk '{ print $4 }')
. cloud/admin-openrc

sed -e "s/@IMAGE_UUID@/$IMAGE_UUID/g" -e "s/@CONTROLLER_IP@/$controller_address/g" \
    -e "s/@SECRET@/$secret/g" -e "s/@ACCESS@/$access/g" \
    $mydir/tempest.conf.in > ~/tempest/etc/tempest.conf
cd ~/tempest
python -m unittest discover -v
