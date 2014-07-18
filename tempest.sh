#!/bin/bash -x
mydir=$(dirname $(readlink -f $0))
sudo apt-get install -y python-pip
git clone https://github.com/openstack/tempest.git ~/tempest
. ~/ubuntu-openrc
IMAGE_UUID=`glance image-list | awk '/linaro.*ami/{print $2}'`
access=$(keystone ec2-credentials-create | grep access | awk '{ print $4 }')
secret=$(keystone ec2-credentials-get --access $access | grep secret | awk '{ print $4 }')

unitAddress()
{
	juju status $1 | python -c "import yaml; import sys; print yaml.load(sys.stdin)[\"services\"][\"$1\"][\"units\"][\"$1/$2\"][\"public-address\"]" 2> /dev/null
}
controller_address=$(unitAddress keystone 0)

sed -e "s/@IMAGE_UUID@/$IMAGE_UUID/g" -e "s/@CONTROLLER_IP@/$controller_address/g" \
    -e "s/@SECRET@/$secret/g" -e "s/@ACCESS@/$access/g" \
    $mydir/tempest.conf.in > ~/tempest/etc/tempest.conf
if [ "$LAVA_RUN_TEMPEST" = "yes" ]; then
    cd ~/tempest
    sudo pip install -r requirements.txt
    testr init
    testr list-tests $LAVA_TESTS_TO_RUN | tail -n +6 > /home/ubuntu/all-tests.txt
    testr run --parallel --subunit --load-list=/home/ubuntu/all-tests.txt | tail -n +6 | tee results.subunit | subunit-2to1 | tools/colorizer.py
    sudo apt-get install -y subunit
    cat results.subunit | subunit2csv --no-passthrough > /home/ubuntu/results.csv

    sudo -E PATH=$PATH lava-test-run-attach /home/ubuntu/all-tests.txt
    sudo -E PATH=$PATH lava-test-run-attach /home/ubuntu/results.csv
    python $mydir/simplify-results.py /home/ubuntu/results.csv  /home/ubuntu/all-tests.txt
fi
