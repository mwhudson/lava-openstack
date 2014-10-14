#!/bin/bash -ex

mydir=$(dirname $(readlink -f $0))

sudo apt-get -y install qemu-system libvirt-bin python-libvirt ntpdate

sudo ntpdate ntp.ubuntu.com

git clone git://github.com/mwhudson/devstack.git -b arm64-trusty-icehouse

cp $mydir/local.sh ./devstack
cp $mydir/local.conf ./devstack

sudo modprobe nbd

chown -R ubuntu:ubuntu ./devstack
cd ./devstack
export DEVSTACK_ROOT=`pwd`
su --login --shell "/bin/bash" ubuntu <<EOF
export PATH=/sbin:/usr/sbin:$PATH
env
cd ${DEVSTACK_ROOT}
./stack.sh
EOF
