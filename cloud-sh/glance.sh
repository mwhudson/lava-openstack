#!/bin/bash -xe

. cloud/admin-openrc

cd "$(mktemp -d)"

IMAGE_NAME=linaro-minimal
IMAGE_URL=http://people.linaro.org/~mwhudson/linaro-minimal-arm64-uec-psci.tar.gz
#IMAGE_NAME=trusty-server
#IMAGE_URL=http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-`dpkg --print-architecture`.tar.gz

wget --progress=dot -e dotbytes=10M -O uec.tar.gz $IMAGE_URL

mkdir uec && cd uec && tar xfz ../uec.tar.gz

KERNEL=$(for f in "./"*-vmlinuz* "./"aki-*/image; do
    [ -f "$f" ] && echo "$f" && break; done; true)
IMAGE=$(for f in "./"*.img "./"ami-*/image; do
    [ -f "$f" ] && echo "$f" && break; done; true)

IMG_PROPERTY=" --property hw_machine_type=virt  --property hw_cdrom_bus=virtio"

sudo mount-image-callback --verbose $IMAGE -- sh -xc 'cp -v $MOUNTPOINT/boot/initrd* . && chmod ugo+r initrd*'

if [ -e initrd* ]; then
    RAMDISK_ID=$(glance image-create --name "$IMAGE_NAME-ramdisk" --is-public True --container-format ari --disk-format ari < initrd* | grep ' id ' |  awk -F'[ \t]*\\|[ \t]*' '{ print $3 }')
    IMG_PROPERTY="$IMG_PROPERTY --property ramdisk_id=$RAMDISK_ID"
    COMMANDLINE="root=LABEL=cloudimg-rootfs rw rootwait console=ttyAMA0"
else
    COMMANDLINE=""
fi

KERNEL_ID=$(glance image-create --name "$IMAGE_NAME-kernel" --is-public True --container-format aki --disk-format aki < "$KERNEL" | grep ' id ' | awk -F'[ \t]*\\|[ \t]*' '{ print $3 }')

IMG_PROPERTY="$IMG_PROPERTY --property kernel_id=$KERNEL_ID"

IMAGE_UUID=$(glance image-create --name "${IMAGE_NAME}" $IMG_PROPERTY --is-public True --container-format ami --disk-format ami < "${IMAGE}" | grep ' id ' | awk -F'[ \t]*\\|[ \t]*' '{ print $3 }')

if [ -n "$COMMANDLINE" ]; then
    glance image-update $IMAGE_UUID --property os_command_line="$COMMANDLINE"
fi
