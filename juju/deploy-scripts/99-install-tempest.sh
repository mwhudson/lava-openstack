# Creates a container, installed tempest and its dependencies in that
# container and creates a script to run another script inside said
# container.
#
# All of this could/should be done by a tempest charm instead, but
# that doesn't exist yet.

host=$(add-new-lxc)

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

grep -n XXX /tmp/tempest.conf

juju scp /tmp/tempest.conf $host:tempest/etc/
cat > ~/run-in-tempest-dir.sh <<EOF
#!/bin/sh -x
juju scp \$1 $host:script.sh
juju ssh $host "cd tempest && LAVA_TESTS_TO_RUN=\$LAVA_TESTS_TO_RUN LAVA_RUN_TEMPEST=\$LAVA_RUN_TEMPEST ../script.sh"
juju scp $host:output.tgz ~/
EOF
chmod u+x ~/run-in-tempest-dir.sh

cat ~/run-in-tempest-dir.sh
