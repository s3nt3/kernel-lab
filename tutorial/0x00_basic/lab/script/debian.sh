#!/bin/bash

KERNEL_VERSION=5.10.133
KERNEL_DIR=/opt/lab/kernel/v${KERNEL_VERSION:0:1}.x/linux-${KERNEL_VERSION}

qemu-system-x86_64 -s -S \
    -smp 2,cores=2,threads=1 -m 2048 \
    -drive format=qcow2,file=/opt/lab/debian.qcow2 \
    -kernel ${KERNEL_DIR}/arch/x86/boot/bzImage \
    -append "root=/dev/sda rw console=ttyS0 oops=panic panic=1" \
    -net user,hostfwd=tcp::22-:22 -net nic \
    -monitor tcp:localhost:23,server,nowait \
    -nographic
