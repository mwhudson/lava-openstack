# This script (which runs as ubuntu) creates an appropriate
# tempest.conf for the openstack cloud that we've just deployed.
#
# This could/should be done by a tempest charm instead, but that
# doesn't exist yet.

IMAGE_UUID=`cat ~/image-uuid`

. ~/ubuntu-openrc
access=$(keystone ec2-credentials-create | grep access | awk '{ print $4 }')
secret=$(keystone ec2-credentials-get --access $access | grep secret | awk '{ print $4 }')

controller_address=$(unit-address keystone 0)

sed -e "s/@IMAGE_UUID@/$IMAGE_UUID/g" -e "s/@CONTROLLER_IP@/$controller_address/g" \
    -e "s/@SECRET@/$secret/g" -e "s/@ACCESS@/$access/g" \
    deploy-data/tempest.conf.in > /tmp/tempest.conf
