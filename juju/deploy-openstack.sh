#!/bin/bash -ex

mydir=$(dirname $(readlink -f $0))

sudo apt-get install -y python-openstackclient python-virtualenv

sudo cp $mydir/utils/* /usr/local/bin
sudo virtualenv /usr/local/venv
sudo /usr/local/venv/bin/pip install shyaml
sudo ln -s /usr/local/venv/bin/shyaml /usr/local/bin

${mydir}/deploy-services.sh

${mydir}/configure-openstack.sh

${mydir}/install-tempest.sh
