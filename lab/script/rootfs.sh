#!/bin/bash

DEBIAN_ARCH=${DEBIAN_ARCH:-amd64}
DEBIAN_DIST=${DEBIAN_DIST:-bullseye}

DEBIAN_DIR=/root/.cache/kernel-lab/debian/${DEBIAN_DIST}/${DEBIAN_ARCH}

if [ ! -d ${DEBIAN_DIR} ] 
then
    mkdir -p ${DEBIAN_DIR}
fi

qemu-img create ${DEBIAN_DIR}/debian.img 64G && mkfs.ext4 ${DEBIAN_DIR}/debian.img
mkdir -p ${DEBIAN_DIR}/.rootfs && mount ${DEBIAN_DIR}/debian.img ${DEBIAN_DIR}/.rootfs

if [ -d ${DEBIAN_DIR}/rootfs ] 
then
    cp -r ${DEBIAN_DIR}/rootfs/* ${DEBIAN_DIR}/.rootfs
else
    debootstrap --arch ${DEBIAN_ARCH} ${DEBIAN_DIST} ${DEBIAN_DIR}/rootfs https://deb.debian.org/debian
    cp -r ${DEBIAN_DIR}/rootfs/* ${DEBIAN_DIR}/.rootfs
fi

chroot ${DEBIAN_DIR}/.rootfs /bin/sh -c "echo 'auto enp0s3' >> /etc/network/interfaces"
chroot ${DEBIAN_DIR}/.rootfs /bin/sh -c "echo 'allow-hotplug enp0s3' >> /etc/network/interfaces"
chroot ${DEBIAN_DIR}/.rootfs /bin/sh -c "echo 'iface enp0s3 inet dhcp' >> /etc/network/interfaces"

echo "[*] Please set the root password for your virtaul machine!"
chroot ${DEBIAN_DIR}/.rootfs /bin/sh -c "/bin/passwd"

umount ${DEBIAN_DIR}/.rootfs

echo "[*] Generate ${DEBIAN_DIR}/debian.qcow2."
qemu-img convert -f raw -O qcow2 ${DEBIAN_DIR}/debian.img ${DEBIAN_DIR}/debian.qcow2 && \
    rm ${DEBIAN_DIR}/debian.img && rm -rf ${DEBIAN_DIR}/.rootfs
