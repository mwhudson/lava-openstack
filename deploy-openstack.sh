#!/bin/bash -x
# This runs as ubuntu.

sudo chown ubuntu:ubuntu cloud-sh
sudo apt-get install -y python-openstackclient
cd cloud-sh
./openstack.sh
