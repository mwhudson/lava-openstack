#!/bin/bash -x

# This script is run in the tempest directory by the
# 'run-in-tempest-dir' script the deploy step created.

if [ ! -d .testrepository ]; then
    testr init
fi
mkdir ~/output
cp etc/tempest.conf ~/output/tempest_conf.txt
if [ "$LAVA_RUN_TEMPEST" = "yes" ]; then
    testr list-tests $LAVA_TESTS_TO_RUN | tail -n +6 > /home/ubuntu/output/all-tests.txt
    OS_TEST_TIMEOUT=1200 testr run --parallel --concurrency=4 --subunit --load-list=/home/ubuntu/output/all-tests.txt | tail -n +6 > results.subunit
#    OS_TEST_TIMEOUT=1200 tox -eall -- --concurrency=4 --load-list=/home/ubuntu/output/all-tests.txt
#    testr last --subunit > results.subunit
    sudo apt-get update
    sudo apt-get install -y subunit
    cat results.subunit | subunit2csv --no-passthrough > /home/ubuntu/output/results.csv
    cat results.subunit | subunit-filter -F | subunit-ls --no-passthrough > /home/ubuntu/output/failing-tests.txt
    cat results.subunit | gzip > /home/ubuntu/output/results.subunit.gz
fi
tar -cvzf ~/output.tgz -C ~ output
