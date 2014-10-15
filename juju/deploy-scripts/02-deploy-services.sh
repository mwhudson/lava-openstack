# This script (which runs as ubuntu) uses juju to deploy and relate
# the services that make up openstack.

waitForService()
{
	for service; do
		while [ "$(unit-agent-state "$service" 0)" != started ]; do
			sleep 5
		done
	done
}

juju deploy --to 0     --config deploy-data/config.yaml nova-compute
juju deploy --to lxc:0 --config deploy-data/config.yaml mysql
juju deploy --to lxc:0                                  rabbitmq-server
juju deploy --to lxc:0 --config deploy-data/config.yaml keystone
juju deploy --to lxc:0                                  nova-cloud-controller
juju deploy --to lxc:0                                  glance
juju deploy --to lxc:0 --config deploy-data/config.yaml swift-proxy
juju deploy --to 0     --config deploy-data/config.yaml swift-storage

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

