# Create the ~/admin-openrc file, the ubuntu & ubuntu_alt users and
# the ~/ubuntu-openrc file.

juju get keystone > /tmp/keystone-config.yaml
keystone-config-val () {
    cat /tmp/keystone-config.yaml | shyaml get-value settings.${1}.value
}

REGION=$(keystone-config-val region)
PORT=$(keystone-config-val service-port)
controller_address=$(unit-address keystone 0)
add-subst CONTROLLER_IP $controller_address

configOpenrc()
{
	cat <<-EOF
		export OS_USERNAME=$1
		export OS_PASSWORD=$2
		export OS_TENANT_NAME=$3
		export OS_AUTH_URL=http://$controller_address:$PORT/v2.0
		export OS_REGION_NAME=$REGION
		EOF
}

ADMIN_USER=$(keystone-config-val admin-user)
ADMIN_PASS=$(keystone-config-val admin-password)

# The 'admin' tenant is hard-coded into the keystone charm.
configOpenrc $ADMIN_USER $ADMIN_PASS admin > ~/admin-openrc

. ~/admin-openrc

# These should use add-subst rather than having an implicit dependence
# between tempest.conf.in and what this script does.

keystone tenant-create --name ubuntu --description "Created by Juju"
keystone user-create --name ubuntu --tenant ubuntu --pass password --email juju@localhost
keystone tenant-create --name ubuntu_alt --description "Created by Juju"
keystone user-create --name ubuntu_alt --tenant ubuntu_alt --pass password --email juju_alt@localhost

configOpenrc ubuntu password ubuntu > ~/ubuntu-openrc
