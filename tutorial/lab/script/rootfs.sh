#!/bin/bash

DEBIAN_ARCH=amd64
DEBIAN_DIST=bullseye

TARGET_DIR=/opt/lab/.cache/debian/${DEBIAN_DIST}/${DEBIAN_ARCH}

qemu-img create /opt/lab/debian.img 64G && mkfs.ext4 /opt/lab/debian.img

mkdir -p /opt/lab/.rootfs && mount /opt/lab/debian.img /opt/lab/.rootfs

if [ -d ${TARGET_DIR} ] 
then
    cp -r ${TARGET_DIR}/* /opt/lab/.rootfs
else
    qemu-debootstrap --arch ${DEBIAN_ARCH} ${DEBIAN_DIST} ${TARGET_DIR} https://deb.debian.org/debian
    cp -r ${TARGET_DIR}/* /opt/lab/.rootfs
fi

chroot /opt/lab/.rootfs /bin/sh -c "echo 'auto enp0s3' >> /etc/network/interfaces"
chroot /opt/lab/.rootfs /bin/sh -c "echo 'allow-hotplug enp0s3' >> /etc/network/interfaces"
chroot /opt/lab/.rootfs /bin/sh -c "echo 'iface enp0s3 inet dhcp' >> /etc/network/interfaces"

echo "[*] Please set the root password for your virtaul machine!"
chroot /opt/lab/.rootfs /bin/sh -c "/bin/passwd"

umount /opt/lab/.rootfs

echo "[*] Generate /opt/lab/debian.qcow2."
qemu-img convert -f raw -O qcow2 /opt/lab/debian.img /opt/lab/debian.qcow2 && \
    rm /opt/lab/debian.img && rm -rf /opt/lab/.rootfs
