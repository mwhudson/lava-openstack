#!/bin/bash -x
# This runs as ubuntu.

sudo chown ubuntu:ubuntu cloud-sh
sudo apt-get install python-openstackclient
cd cloud-sh
./openstack.sh

cp cloud/* ~

. cloud/ubuntu-openrc

sleep 10

nova boot --image linaro-minimal linaro.tiny --flavor m1.tiny --poll

sleep 10

nova console-log linaro.tiny

nova list
