#!/bin/bash -ex

cd $(dirname $(readlink -f $0))

# This script (which runs as ubuntu) runs the scripts in deploy-scripts
# (in alpabetical order) to set up the openstack deployed by
# deploy-services.sh in readiness for running tempest.

for script in deploy-scripts/*.sh; do
    echo "executing ${script} ..."
    bash -ex "${script}"
done

# import key pair

