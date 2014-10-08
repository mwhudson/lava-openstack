#!/bin/bash -x
mydir=$(dirname $(readlink -f $0))

. ~/ubuntu-openrc
IMAGE_UUID=`glance image-list | awk '/trusty.*ami/{print $2}'`
access=$(keystone ec2-credentials-create | grep access | awk '{ print $4 }')
secret=$(keystone ec2-credentials-get --access $access | grep secret | awk '{ print $4 }')

unitAddress()
{
	juju status $1 | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"public-address\"]" 2> /dev/null
}

controller_address=$(unitAddress keystone 0)

. ~/admin-openrc
nova flavor-create m1.nano 42 64 0 1
nova flavor-create m1.micro 84 128 0 1


sed -e "s/@IMAGE_UUID@/$IMAGE_UUID/g" -e "s/@CONTROLLER_IP@/$controller_address/g" \
    -e "s/@SECRET@/$secret/g" -e "s/@ACCESS@/$access/g" \
    $mydir/tempest.conf.in > /tmp/tempest.conf
host=$($mydir/add-new-lxc.py)

cat > /tmp/install.sh <<EOF
sudo apt-get update
sudo apt-get install -y bridge-utils pylint python-setuptools screen unzip wget psmisc git openssh-server openssl python-virtualenv python-unittest2 iputils-ping wget curl tcpdump euca2ools tar python-dev python2.7 bc libxslt1-dev zlib1g-dev 
git clone https://github.com/openstack/tempest.git ~/tempest
cd ~/tempest
sudo pip install -r requirements.txt
testr init
EOF
juju scp /tmp/install.sh $host:
juju ssh $host sh -x install.sh
juju scp /tmp/tempest.conf $host:tempest/etc/
cat > ~/run-in-tempest-dir.sh <<EOF
#!/bin/sh -x
juju scp \$1 $host:script.sh
juju ssh $host "cd tempest && LAVA_TESTS_TO_RUN=\$LAVA_TESTS_TO_RUN LAVA_RUN_TEMPEST=\$LAVA_RUN_TEMPEST ../script.sh"
juju scp $host:output.tgz ~/
EOF
chmod u+x ~/run-in-tempest-dir.sh
cat ~/run-in-tempest-dir.sh
