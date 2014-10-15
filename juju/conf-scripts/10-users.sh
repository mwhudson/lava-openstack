unitAddress()
{
	juju status | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"public-address\"]" 2> /dev/null
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

controller_address=$(unitAddress keystone 0)
# XXX would be better to read this out of `juju get keystone`
configOpenrc admin password admin http://$controller_address:5000/v2.0 RegionOne > ~/admin-openrc

. ~/admin-openrc

keystone tenant-create --name ubuntu --description "Created by Juju"
keystone user-create --name ubuntu --tenant ubuntu --pass password --email juju@localhost
keystone tenant-create --name ubuntu_alt --description "Created by Juju"
keystone user-create --name ubuntu_alt --tenant ubuntu_alt --pass password --email juju_alt@localhost

configOpenrc ubuntu password ubuntu http://$controller_address:5000/v2.0 RegionOne > ~/ubuntu-openrc
