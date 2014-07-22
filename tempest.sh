#!/bin/bash -x
mydir=$(dirname $(readlink -f $0))
cd ~/tempest
sudo pip install -r requirements.txt
testr init
if [ "$LAVA_RUN_TEMPEST" = "yes" ]; then
    testr list-tests $LAVA_TESTS_TO_RUN | tail -n +6 > /home/ubuntu/all-tests.txt
    OS_TEST_TIMEOUT=1200 testr run --subunit --load-list=/home/ubuntu/all-tests.txt | tail -n +6 | tee results.subunit | subunit-2to1 | tools/colorizer.py
    sudo apt-get install -y subunit
    cat results.subunit | subunit2csv --no-passthrough > /home/ubuntu/results.csv

    sudo -E PATH=$PATH lava-test-run-attach /home/ubuntu/all-tests.txt
    sudo -E PATH=$PATH lava-test-run-attach /home/ubuntu/results.csv
    python $mydir/simplify-results.py /home/ubuntu/results.csv  /home/ubuntu/all-tests.txt
fi
