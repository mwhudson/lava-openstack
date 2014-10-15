#!/bin/bash -ex

# This script (which runs as ubuntu) runs the scripts in conf-scripts
# (in alpabetical order) to set up the openstack deployed by
# deploy-services.sh in readiness for running tempest.

for script in "$mydir/conf-scripts/*.sh"; do
    echo "executing ${script} ..."
    bash -ex ${script}
done

# import key pair

