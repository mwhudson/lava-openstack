#!/bin/bash -ex

cd $(dirname $(readlink -f $0))

# This script (which runs as ubuntu) runs the scripts in deploy-scripts
# (in alpabetical order) to set up the openstack deployed by
# deploy-services.sh in readiness for running tempest.

cp deploy-data/tempest.conf.in /tmp/tempest.conf

for script in deploy-scripts/*.sh; do
    bash -ex "${script}"
done

