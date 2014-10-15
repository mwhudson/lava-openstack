# Create an appropriate tempest.conf for the openstack cloud that
# we've just deployed, using the values in calls to add-subst by
# previous steps.
#
# This could/should be done by a tempest charm instead, but that
# doesn't exist yet.

cat /tmp/tempest-substs

sed -f /tmp/tempest-substs deploy-data/tempest.conf.in > /tmp/tempest.conf
