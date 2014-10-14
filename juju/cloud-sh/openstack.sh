#!/bin/bash -ex

agentStateUnit()
{
	juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"agent-state\"]" 2> /dev/null
}

configOpenrc()
{
	cat <<-EOF
		export OS_USERNAME=$1
		export OS_PASSWORD=$2
		export OS_TENANT_NAME=$3
		export OS_AUTH_URL=$4
		export OS_REGION_NAME=$5
		EOF
}

unitAddress()
{
	juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"public-address\"]" 2> /dev/null
}

waitForService()
{
	for service; do
		while [ "$(agentStateUnit "$service" 0)" != started ]; do
			sleep 5
		done
	done
}

juju deploy --to 0     --config config.yaml nova-compute
juju deploy --to lxc:0 --config config.yaml mysql

juju deploy --to lxc:0                      rabbitmq-server
juju deploy --to lxc:0 --config config.yaml keystone
juju deploy --to lxc:0                      nova-cloud-controller
juju deploy --to lxc:0                      glance
juju deploy --to lxc:0 --config config.yaml swift-proxy
juju deploy --to 0     --config config.yaml swift-storage

# relation must be set first
# no official way of knowing when this relation hook will fire
waitForService mysql keystone
juju add-relation keystone mysql
sleep 120

juju add-relation nova-cloud-controller:shared-db mysql:shared-db
juju add-relation nova-cloud-controller rabbitmq-server
juju add-relation nova-cloud-controller glance
juju add-relation nova-cloud-controller keystone
juju add-relation nova-compute:shared-db mysql:shared-db
juju add-relation nova-compute:amqp rabbitmq-server:amqp
juju add-relation nova-compute glance
juju add-relation nova-compute nova-cloud-controller
juju add-relation glance:shared-db mysql:shared-db
juju add-relation glance keystone
juju add-relation swift-proxy keystone
juju add-relation swift-proxy swift-storage

waitForService rabbitmq-server nova-cloud-controller glance nova-compute swift-proxy swift-storage
# no official way of knowing when relation hooks have fired
juju status
sleep 240
juju status

controller_address=$(unitAddress keystone 0)
configOpenrc admin password admin http://$controller_address:5000/v2.0 RegionOne > ~/admin-openrc
configOpenrc ubuntu password ubuntu http://$controller_address:5000/v2.0 RegionOne > ~/ubuntu-openrc

./glance.sh

. ~/admin-openrc

# create ubuntu user
keystone tenant-create --name ubuntu --description "Created by Juju"
keystone user-create --name ubuntu --tenant ubuntu --pass password --email juju@localhost
keystone tenant-create --name ubuntu_alt --description "Created by Juju"
keystone user-create --name ubuntu_alt --tenant ubuntu_alt --pass password --email juju_alt@localhost

# configure security groups
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

# import key pair
nova keypair-add --pub-key ~/.ssh/id_rsa.pub ubuntu-keypair

juju scp cloud-setup.sh nova-clouad-controller/0:
juju run --unit nova-clouad-controller/0: ./cloud-setup.sh

