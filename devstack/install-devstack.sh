#!/bin/bash -xe
apt-get update
apt-get -y install lsb-release git nmap vim pm-utils bridge-utils openssh-server subunit

cp ~/devstack/tempest-run-in-tempest-dir.sh /home/ubuntu/run-in-tempest-dir.sh

d=$(mktemp -d)
chmod -R a+rX $d
git clone -b arm64-trusty git://github.com/mwhudson/testing-openstack
chmod -R a+rX testing-openstack

cd testing-openstack

exec 1>/dev/tty
exec 2>/dev/tty
./setup.sh

sleep 60
if [ "$LAVA_SLEEP_FOR_ACCESS" = "yes" ]; then
    sleep $LAVA_SLEEP_DURATION
fi
