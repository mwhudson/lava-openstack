#!/bin/bash -ex

mydir=$(dirname $(readlink -f $0))

sudo apt-get install -y python-openstackclient

./deploy-services.sh

./configure-openstack.sh

./install-tempest.sh
