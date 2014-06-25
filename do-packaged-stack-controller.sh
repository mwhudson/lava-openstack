#!/bin/bash -x
# This runs as ubuntu.

mkdir ~/.juju
sed -e "s/@BOOTSTRAP_IP@/$BOOTSTRAP_IP/" ./environments.yaml > ~/.juju/environments.yaml
cp ./minimal-juju-deploy.yaml ~
juju bootstrap

for machine_ip in $MACHINE_IPS; do
    juju add-machine ssh:$machine_ip
done

cd
juju-deployer -e manual -c minimal-juju-deploy.yaml

export OS_USERNAME=admin
export OS_PASSWORD=openstack
export OS_TENANT_NAME=admin
export OS_REGION_NAME=RegionOne
export OS_AUTH_URL=${OS_AUTH_PROTOCOL:-http}://`juju-deployer -f keystone`:5000/v2.0

wget --progress=dot -e dotbytes=10M http://people.linaro.org/~mwhudson/linaro-minimal-arm64-uec-psci.tar.gz
mkdir uec
cd uec
tar xfz ../linaro-minimal-arm64-uec-psci.tar.gz
IMAGE_NAME=linaro-minimal
KERNEL=$(for f in "./"*-vmlinuz* "./"aki-*/image; do
    [ -f "$f" ] && echo "$f" && break; done; true)
IMAGE=$(for f in "./"*.img "./"ami-*/image; do
    [ -f "$f" ] && echo "$f" && break; done; true)

IMG_PROPERTY=" --property hw_machine_type=virt  --property hw_cdrom_bus=virtio"

KERNEL_ID=$(glance image-create --name "$IMAGE_NAME-kernel" --is-public True --container-format aki --disk-format aki < "$KERNEL" | grep ' id ' | awk -F'[ \t]*\\|[ \t]*' '{ print $3 }')

glance image-create --name "${IMAGE_NAME}" $IMG_PROPERTY --is-public True --container-format ami --disk-format ami --property kernel_id=$KERNEL_ID < "${IMAGE}"
IMAGE_UUID=`glance image-list | awk '/linaro.*ami/{print $2}'`
glance image-update $IMAGE_UUID --property os_command_line='root=/dev/vdb rw rootwait console=ttyAMA0'

nova boot --image linaro-minimal linaro.tiny --flavor m1.tiny --poll
