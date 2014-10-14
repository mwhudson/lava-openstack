#!/bin/bash

TOP_DIR=$(cd $(dirname "$0") && pwd)

# Get OpenStack admin auth
source $TOP_DIR/openrc admin admin

# create SSH key if not present
echo "Create Linaro SSH keypair"
KEY_NAME=LinaroKey
if [[ -z $(nova keypair-list | grep $KEY_NAME) ]]; then
    nova keypair-add --pub-key ~/.ssh/id_rsa.pub ${KEY_NAME}
fi

# set property of image to run as virt model
echo "Update image with properties required to run as a mach-virt guest"
IMAGE_UUID=`glance image-list | awk '/linaro.*ami/{print $2}'`
glance image-update $IMAGE_UUID --property hw_machine_type=virt
glance image-update $IMAGE_UUID --property hw_cdrom_bus=virtio
glance image-update $IMAGE_UUID --property os_command_line='root=/dev/vdb rw rootwait console=ttyAMA0'
