#!/bin/bash

KERNEL_VERSION=${KERNEL_VERSION:-5.10.133}

TARGET_DIR=/root/.cache/kernel-lab/kernel/v${KERNEL_VERSION:0:1}.x

mkdir -p ${TARGET_DIR}

if [ ! -f ${TARGET_DIR}/linux-${KERNEL_VERSION}.tar.xz ]
then
    wget https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_VERSION:0:1}.x/linux-${KERNEL_VERSION}.tar.xz -P ${TARGET_DIR}
fi

if [ ! -f ${TARGET_DIR}/linux-${KERNEL_VERSION}.tar.sign ]
then
    wget https://cdn.kernel.org/pub/linux/kernel/v${KERNEL_VERSION:0:1}.x/linux-${KERNEL_VERSION}.tar.sign -P ${TARGET_DIR}
fi
