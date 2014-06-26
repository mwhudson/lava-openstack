#!/bin/bash -x
# This runs as ubuntu.

mkdir ~/.juju
sed -e "s/@BOOTSTRAP_IP@/$BOOTSTRAP_IP/" ./environments.yaml | tee ~/.juju/environments.yaml
cp ./minimal-juju-deploy.yaml ~
juju bootstrap

for machine_ip in $MACHINE_IPS; do
    juju add-machine ssh:$machine_ip
done

sudo chown ubuntu:ubuntu cloud-sh
cd cloud-sh
./openstack.sh

nova boot --image linaro-minimal linaro.tiny --flavor m1.tiny --poll
