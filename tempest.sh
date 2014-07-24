#!/bin/bash -x
mydir=$(dirname $(readlink -f $0))
if [ ! -d .testrepository ]; then
    testr init
fi
mkdir ~/output
cp etc/tempest.conf ~/output
if [ "$LAVA_RUN_TEMPEST" = "yes" ]; then
    testr list-tests $LAVA_TESTS_TO_RUN | tail -n +6 > /home/ubuntu/output/all-tests.txt
    OS_TEST_TIMEOUT=1200 testr run --subunit --load-list=/home/ubuntu/output/all-tests.txt | tail -n +6 | tee results.subunit | subunit-2to1 | tools/colorizer.py
    sudo apt-get install -y subunit
    cat results.subunit | subunit2csv --no-passthrough > /home/ubuntu/output/results.csv
fi
