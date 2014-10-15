# Create ec2 credentials for tempest to use.
. ~/ubuntu-openrc

controller_address=$(unit-address keystone 0)

tempest-set boto s3_url http://$controller_address:3333
tempest-set boto ec2_url http://$controller_address:8773/services/Cloud

ACCESS=$(keystone ec2-credentials-create | grep access | awk '{ print $4 }')
tempest-set boto aws_access $ACCESS
tempest-set boto aws_secret  $(keystone ec2-credentials-get --access $ACCESS | grep secret | awk '{ print $4 }')
