#!/bin/bash

TOP_DIR=$(cd $(dirname "$0") && pwd)

# Get OpenStack admin auth
source $TOP_DIR/openrc admin admin

# set properties of image to run as virt model
echo "Update image with properties required to run as a mach-virt guest"
IMAGE_UUID=`glance image-list | awk '/linaro.*ami/{print $2}'`
# We should make these default/unnecessary on arm64 somehow.
glance image-update $IMAGE_UUID --property hw_machine_type=virt
glance image-update $IMAGE_UUID --property hw_cdrom_bus=virtio
# Now this is a pain.  In an ideal world, the VM would boot via a
# bootloader (i.e. UEFI) and so the image would be able to set its own
# kernel command line.  But it doesn't so we have to be explicit.  And
# the image we use (see local.conf) does not have an initrd so we
# can't use root=LABEL=... so we have to depend on the fact that the
# root device comes up as /dev/vdb (devstack configures nova to use a
# config drive rather than metadata service by default and that ends
# up being /dev/vda).  The order of virtio block devices is not ABI,
# but this works for now.
glance image-update $IMAGE_UUID --property os_command_line='root=/dev/vdb rw rootwait console=ttyAMA0'
