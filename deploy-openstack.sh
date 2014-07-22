#!/bin/bash -ex
echo "hello from deploy-openstack.sh" $PATH
sudo chown ubuntu:ubuntu cloud-sh
sudo apt-get install -y python-openstackclient
cd cloud-sh
./openstack.sh
cp cloud/* ~/
cd ../
./install-tempest.sh
