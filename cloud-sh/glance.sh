#!/bin/sh -xe

. cloud/admin-openrc

IMAGE_NAME=linaro-minimal
IMAGE_URL=http://people.linaro.org/~mwhudson/linaro-minimal-arm64-uec-psci.tar.gz
IMAGE_NAME=trusty-server
IMAGE_URL=http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-`dpkg --print-architecture`.tar.gz

wget --progress=dot -e dotbytes=10M -O uec.tar.gz $IMAGE_URL

mkdir uec && cd uec && tar xfz ../uec.tar.gz

KERNEL=$(for f in "./"*-vmlinuz* "./"aki-*/image; do
    [ -f "$f" ] && echo "$f" && break; done; true)
IMAGE=$(for f in "./"*.img "./"ami-*/image; do
    [ -f "$f" ] && echo "$f" && break; done; true)

IMG_PROPERTY=" --property hw_machine_type=virt  --property hw_cdrom_bus=virtio"

sudo mount-image-callback trusty-server-cloudimg-arm64.img -- sh -c 'cp $MOUNTPOINT/boot/initrd* . && chmod ugo+r initrd*'

RAMDISK_ID=$(glance image-create --name "$IMAGE_NAME-ramdisk" --is-public True --container-format ari -disk-format ari < initrd* | grep ' id ' |  awk -F'[ \t]*\\|[ \t]*' '{ print $3 }')

KERNEL_ID=$(glance image-create --name "$IMAGE_NAME-kernel" --is-public True --container-format aki --disk-format aki < "$KERNEL" | grep ' id ' | awk -F'[ \t]*\\|[ \t]*' '{ print $3 }')

IMAGE_UUID=$(glance image-create --name "${IMAGE_NAME}" $IMG_PROPERTY --is-public True --container-format ami --disk-format ami --property kernel_id=$KERNEL_ID --property ramdisk_id=$RAMDISK_ID < "${IMAGE}" | grep ' id ' | awk -F'[ \t]*\\|[ \t]*' '{ print $3 }')

glance image-update $IMAGE_UUID --property os_command_line='root=LABEL=cloudimg-rootfs rw rootwait console=ttyAMA0'
