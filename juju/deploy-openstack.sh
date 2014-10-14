#!/bin/bash -ex

mydir=$(dirname $(readlink -f $0))

sudo apt-get install -y python-openstackclient

${mydir}/deploy-services.sh

${mydir}/configure-openstack.sh

${mydir}/install-tempest.sh
