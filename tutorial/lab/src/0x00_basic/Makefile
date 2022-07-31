KERNEL_VERSION=5.10.133
KERNEL_VERSION_PREFIX=$(shell echo ${KERNEL_VERSION} | cut -c 1-1)

obj-m += hello-1.o
obj-m += hello-2.o
obj-m += hello-3.o
obj-m += hello-4.o
obj-m += hello-5.o

all:
		$(MAKE) -C /opt/lab/.cache/kernel/v$(KERNEL_VERSION_PREFIX).x/linux-$(KERNEL_VERSION) CC=$(CC) M=$(PWD) modules

clean:
		$(MAKE) -C /opt/lab/.cache/kernel/v$(KERNEL_VERSION_PREFIX).x/linux-$(KERNEL_VERSION) CC=$(CC) M=$(PWD) clean
