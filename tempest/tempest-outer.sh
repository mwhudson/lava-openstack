#!/bin/bash -xe
sudo -u ubuntu -E ~/run-in-tempest-dir.sh ./tempest/tempest-inner.sh
cd
tar -xvzf output.tgz
cd output
for i in *; do
    lava-test-run-attach "$i"
done
python $(readlink -f $0)/print-results.py results.csv all-tests.txt
set +e
kill $(fuser 80/tcp 2>/dev/null)
if ip addr show dev br100; then
    ip addr del dev br100 192.168.1.0/24
fi
