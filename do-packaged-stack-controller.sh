#!/bin/bash -x
# This runs as ubuntu.

mkdir ~/.juju
sed -e "s/@BOOTSTRAP_IP@/$BOOTSTRAP_IP/" ./environments.yaml | tee ~/.juju/environments.yaml
cp ./minimal-juju-deploy.yaml ~
juju bootstrap

if [ -n "$MACHINE_IPS" ]; then
    for machine_ip in $MACHINE_IPS; do
        juju add-machine ssh:$machine_ip
    done
else
    sleep 10
fi

sudo chown ubuntu:ubuntu cloud-sh
cd cloud-sh
./openstack.sh

. cloud/ubuntu-openrc

nova boot --image linaro-minimal linaro.tiny --flavor m1.tiny --poll
