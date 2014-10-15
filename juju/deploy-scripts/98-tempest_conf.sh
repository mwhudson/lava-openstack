# This script (which runs as ubuntu) creates an appropriate
# tempest.conf for the openstack cloud that we've just deployed.
#
# This could/should be done by a tempest charm instead, but that
# doesn't exist yet.

cat /tmp/tempest-substs

sed -f /tmp/tempest-substs
    -e "s/@SECRET@/$secret/g" -e "s/@ACCESS@/$access/g" \
    deploy-data/tempest.conf.in > /tmp/tempest.conf
