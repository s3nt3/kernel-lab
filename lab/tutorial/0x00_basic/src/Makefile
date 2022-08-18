KERNEL_VERSION ?= 5.10.133
KERNEL_DIR = /root/.cache/kernel-lab/kernel/v$(shell echo ${KERNEL_VERSION} | cut -c 1-1).x/linux-${KERNEL_VERSION}

obj-m += hello.o
obj-m += chardev.o

all:
		$(MAKE) -C $(KERNEL_DIR) CC=$(CC) M=$(PWD) modules

clean:
		$(MAKE) -C $(KERNEL_DIR) CC=$(CC) M=$(PWD) clean
