#!/bin/bash -ex
sudo chown ubuntu:ubuntu cloud-sh
sudo apt-get install -y python-openstackclient
cd cloud-sh
./openstack.sh
cp cloud/* ~/
cd ../
./install-tempest.sh
