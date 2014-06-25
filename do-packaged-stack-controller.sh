#!/bin/bash -x
# This runs as ubuntu.

mkdir ~/.juju
cp ./environments.yaml ~/.juju
cp ./minimal-juju-deploy.yaml ~
juju bootstrap
juju add-machine ssh:compute01

cd
juju-deployer -e manual -c minimal-juju-deploy.yaml

