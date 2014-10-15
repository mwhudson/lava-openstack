#!/bin/bash -xe

# This script (which runs as root) invokes tempest-inner in the way
# that the deployment step set up and processes the output for LAVA.

mydir=$(dirname $(readlink -f $0))
sudo -u ubuntu -E ~/run-in-tempest-dir.sh ./tempest/tempest-inner.sh
cd
tar -xvzf output.tgz
cd output
for i in *; do
    lava-test-run-attach "$i"
done
python ${mydir}/print-results.py results.csv all-tests.txt
set +e

# These TERRIBLE HACKS are required because LAVA assumes that it can
# set up a httpd on port 80 (and that the networking configuration is
# not too complicated)

kill $(fuser 80/tcp 2>/dev/null)
if ip addr show dev br100; then
    ip addr del dev br100 192.168.1.0/24
fi
