# Create ec2 credentials for tempest to use.
. ~/ubuntu-openrc
ACCESS=$(keystone ec2-credentials-create | grep access | awk '{ print $4 }')
add-subst ACCESS $ACCESS
add-subst SECRET $(keystone ec2-credentials-get --access $ACCESS | grep secret | awk '{ print $4 }')
