#!/bin/bash -xe

mydir=$(dirname $(readlink -f $0))

apt-get update
apt-get -y install lsb-release git nmap vim pm-utils bridge-utils openssh-server subunit qemu-system libvirt-bin python-libvirt ntpdate

cp $mydir/tempest-run-in-tempest-dir.sh /home/ubuntu/run-in-tempest-dir.sh

d=$(mktemp -d)
chmod -R a+rX $d
cd $d

git clone git://github.com/mwhudson/devstack.git -b arm64-master

cp $mydir/local.sh ./devstack
cp $mydir/local.conf ./devstack

sudo modprobe nbd

chown -R ubuntu:ubuntu ./devstack
cd ./devstack
export DEVSTACK_ROOT=`pwd`
exec 1>/dev/tty
exec 2>/dev/tty
su --login --shell "/bin/bash" ubuntu <<EOF
export PATH=/sbin:/usr/sbin:$PATH
env
cd ${DEVSTACK_ROOT}
./stack.sh
EOF

cd /opt/stack/tempest
git fetch https://review.openstack.org/openstack/tempest refs/changes/65/130665/2 && GIT_EDITOR=cat git merge FETCH_HEAD

sleep 60
if [ "$LAVA_SLEEP_FOR_ACCESS" = "yes" ]; then
    sleep $LAVA_SLEEP_DURATION
fi

sudo ntpdate ntp.ubuntu.com
