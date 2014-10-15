. ~/ubuntu-openrc
add-subst ACCESS $(keystone ec2-credentials-create | grep access | awk '{ print $4 }')
add-subst SECRET $(keystone ec2-credentials-get --access $access | grep secret | awk '{ print $4 }')
