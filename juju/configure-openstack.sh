#!/bin/bash -ex

mydir=$(dirname $(readlink -f $0))

unitAddress()
{
	juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"public-address\"]" 2> /dev/null
}

controller_address=$(unitAddress keystone 0)
configOpenrc admin password admin http://${controller_address}:5000/v2.0 RegionOne > ~/admin-openrc
configOpenrc ubuntu password ubuntu http://${controller_address}:5000/v2.0 RegionOne > ~/ubuntu-openrc

for script in "$mydir/conf-scripts/*.sh"; do
    echo "executing ${script} ..."
    bash -ex ${script}
done

# import key pair

