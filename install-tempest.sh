#!/bin/bash
mydir=$(dirname $(readlink -f $0))
sudo apt-get install -y python-pip
git clone https://github.com/openstack/tempest.git ~/tempest
. ~/ubuntu-openrc
IMAGE_UUID=`glance image-list | awk '/linaro.*ami/{print $2}'`
access=$(keystone ec2-credentials-create | grep access | awk '{ print $4 }')
secret=$(keystone ec2-credentials-get --access $access | grep secret | awk '{ print $4 }')

unitAddress()
{
	juju status $1 | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"public-address\"]" 2> /dev/null
}
controller_address=$(unitAddress keystone 0)

sed -e "s/@IMAGE_UUID@/$IMAGE_UUID/g" -e "s/@CONTROLLER_IP@/$controller_address/g" \
    -e "s/@SECRET@/$secret/g" -e "s/@ACCESS@/$access/g" \
    $mydir/tempest.conf.in > ~/tempest/etc/tempest.conf
