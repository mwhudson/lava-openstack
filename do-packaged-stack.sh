#!/bin/bash -x
# This runs as root.
mkdir -p ~ubuntu/.ssh
cp id_rsa* ~ubuntu/.ssh
cat ~ubuntu/.ssh/id_rsa.pub >> ~ubuntu/.ssh/authorized_keys
cat >> ~ubuntu/.ssh/config <<EOF
StrictHostKeyChecking no
EOF
chown -R ubuntu:ubuntu ~ubuntu/.ssh
chmod 0600 ~ubuntu/.ssh/id_rsa
chmod 0644 ~ubuntu/.ssh/id_rsa.pub
chmod 0700 ~ubuntu/.ssh

lava-sync ssh-done

sudo -u ubuntu ssh ubuntu@compute01 true
sudo -u ubuntu ssh ubuntu@controller01 true

if [ `lava-role` = "controller" ]; then
    apt-get install -y juju-core juju-deployer git testrepository subunit python-nose python-lxml python-openstackclient
    sudo -u ubuntu PATH=$PATH ./do-packaged-stack-controller.sh
fi

if [ "$LAVA_SLEEP_FOR_ACCESS" = "yes" ]; then
    sleep 3600
fi

lava-sync all-done
