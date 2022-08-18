# Basic

Before we start to play a kernel pwn challenge, I'd like to introduce some information about how to write and use kernel modules. Because, in the next chapters, we will be dealing with some kernel modules. And not only our tutorials, but also many kernel exploit CTF challenges are based on kernel modules. So, it is very important to learn a bit about kernel modules, before you start your kernel hacking journey.

Since there are lots of great resources available online for free(for example, [The Linux Kernel Module Programming Guide](https://sysprog21.github.io/lkmpg/) and [Linux Kernel Teaching](https://linux-kernel-labs.github.io/refs/heads/master/), which are available online for free, and the most incredible thing is that all the samples in these tutorial work well with the latest 5.x kernel), in this tutorial, I will just briefly introduce the basic concepts and steps to read, compile and run some simple kernel module samples. For more details, please read the references given in every topic.

## Starting a New Virtual Machine

You may have already started a virtual machine using `/root/kernel-lab/script/debian.sh` in the previous tutorial. However, it is recommended that you shutdown it and start a new virtual machine using `/root/kernel-lab/tutorial/0x00_basic/run.sh` for learning current chapter. Since in different chapter different boot parameters may required, so there is a `run.sh` script with specific boot parameters for each chapter. In brief, please remember to restart a new virtual machine when you begin to learn a new chapter.

## What is a Kernel Module?

Kernel modules are pieces of code that can be loaded and unloaded into the kernel upon demand. You can see: [What Is A Kernel Module](https://sysprog21.github.io/lkmpg/#what-is-a-kernel-module) for more details.

## How to Build a Kernel Module

You can execute the `make` command in the `/root/kernel-lab/tutorial/0x00_basic/src` directory to build all the sample code in this chapter:

```
$ make
make -C /root/.cache/kernel-lab/kernel/v5.x/linux-5.10.133 CC=cc M=/root/kernel-lab/tutorial/0x00_basic/src modules
make[1]: Entering directory '/root/.cache/kernel-lab/kernel/v5.x/linux-5.10.133'
  CC [M]  /root/kernel-lab/tutorial/0x00_basic/src/hello.o
  CC [M]  /root/kernel-lab/tutorial/0x00_basic/src/chardev.o
  MODPOST /root/kernel-lab/tutorial/0x00_basic/src/Module.symvers
  CC [M]  /root/kernel-lab/tutorial/0x00_basic/src/chardev.mod.o
  LD [M]  /root/kernel-lab/tutorial/0x00_basic/src/chardev.ko
  CC [M]  /root/kernel-lab/tutorial/0x00_basic/src/hello.mod.o
  LD [M]  /root/kernel-lab/tutorial/0x00_basic/src/hello.ko
make[1]: Leaving directory '/root/.cache/kernel-lab/kernel/v5.x/linux-5.10.133'
```

There are some differences between building kernel modules and user mode programs, so let's take a deeper look at what the Makefile looks like:

```Makefile
KERNEL_VERSION ?= 5.10.133
KERNEL_DIR = /root/.cache/kernel-lab/kernel/v$(shell echo ${KERNEL_VERSION} | cut -c 1-1).x/linux-${KERNEL_VERSION}

obj-m += hello.o
obj-m += chardev.o

all:
                $(MAKE) -C $(KERNEL_DIR) CC=$(CC) M=$(PWD) modules

clean:
                $(MAKE) -C $(KERNEL_DIR) CC=$(CC) M=$(PWD) clean
```

### kbuild

The sample Makefile shows above is aimed at building out-of-tree (or “external”) modules. Due to `kbuild` has hided most of the complexity, so one only has to type “make” to build the module. `kbuild` is the build system used by the Linux kernel. Modules must use `kbuild` to stay compatible with changes in the build infrastructure. Functionality for building modules both in-tree and out-of-tree is provided. The method for building either is similar, and all modules are initially developed and built out-of-tree.

### options

When we write our own Makefile, there are two important options to specify. One is `-C` and the other is `M`, and the command format is shown as follows:

```
make -C $KERNEL_SOURCE_DIR M=$PWD [target]
```

#### -C $KERNEL_SOURCE_DIR

The option `-C` specifies the directory where the kernel source is located. `make` will actually change to the specified directory when executing and will change back when finished.

#### M=$PWD

The options `M` informs `kbuild` that an external module is being built. The value given to option `M` is the absolute path of the directory where the external module is located.

### target

When building an external module, only a subset of the `make` targets are available.

The default will build the module(s) located in the current directory, so a target does not need to be specified. All output files will also be generated in this directory. No attempts are made to update the kernel source, and it is a precondition that a successful `make` has been executed for the kernel.

#### modules

The default target for external modules. It has the same functionality as if no target was specified. See description above.

#### modules_install

Install the external module(s). The default location is /lib/modules/<kernel_release>/extra/, but a prefix may be added with INSTALL_MOD_PATH (discussed in section 5).

#### clean

Remove all generated files in the module directory only.

#### help

List the available targets for external modules.

### goal definitions

One more important thing is to specify which module we need to build. Here we will use something called goal definitions(see [goal definitions](https://docs.kernel.org/kbuild/makefiles.html#goal-definitions) for details), an example is as follow:

```
obj-m := <module_name>.o
```

The `kbuild` system will build <module_name>.o from <module_name>.c, and, after linking, will result in the kernel module <module_name>.ko. When the module is built from multiple sources, an additional line is needed listing the files:

```
<module_name>-y := <src1>.o <src2>.o ...
```

You can see: [Building External Modules](https://docs.kernel.org/kbuild/modules.html) for more details.

## Simple Kernel Module: hello

In `/root/kernel-lab/tutorial/0x00_basic/src/hello.c`, it shows a simple kernel module would look like:

```c
/*
 * hello.c - Demonstrates module documentation.
 */
#include <linux/init.h> /* Needed for the macros */
#include <linux/kernel.h> /* Needed for pr_info() */
#include <linux/module.h> /* Needed by all modules */

MODULE_LICENSE("GPL");
MODULE_AUTHOR("LKMPG");
MODULE_DESCRIPTION("A simple kernel module.");

static int __init init_hello(void)
{
    pr_info("Hello, world\n");
    return 0;
}

static void __exit cleanup_hello(void)
{
    pr_info("Goodbye, world\n");
}

module_init(init_hello);
module_exit(cleanup_hello);
```

Kernel modules must have at least two functions: a "start" (initialization) function called `init_module()` which is called when the module is inserted into the kernel, and an "end" (cleanup) function called `cleanup_module()` which is called just before it is removed from the kernel.

### insert or remove a module

You can use the `insmod` command to insert a kernel module, for example:

```
$ insmod hello.ko
```

And we can use the `dmesg` command to see the output during module initialization:

```
$ dmesg | tail -n 5
[   10.617689] e1000: enp0s3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
[   10.618736] ip (175) used greatest stack depth: 12768 bytes left
[   10.622689] IPv6: ADDRCONF(NETDEV_CHANGE): enp0s3: link becomes ready
[ 1064.531248] hello: loading out-of-tree module taints kernel.
[ 1064.543161] Hello, world
```

If we no longer need this module, we can use the `rmmod` command to remove it from the kernel:

```
$ rmmod hello.ko
```

And the output is as follows:

```
dmesg | tail -n 5
[   10.618736] ip (175) used greatest stack depth: 12768 bytes left
[   10.622689] IPv6: ADDRCONF(NETDEV_CHANGE): enp0s3: link becomes ready
[ 1064.531248] hello: loading out-of-tree module taints kernel.
[ 1064.543161] Hello, world
[ 1124.906761] Goodbye, world
```

### module_init & module_exit

In earlier versions of the kernel, you had to use the `init_module` and `cleanup_module` functions, but now you can name what you want by using the `module_init` and `module_exit` macros, which is shown in `hello.c`.

The only requirement is that your init and cleanup functions must be defined before you call these macros, otherwise you will get compilation errors.

### __init & __exit

In `hello.c`, it shows the usage of `__init` and `__exit`.

The `__init` macro causes the init function to be discarded and its memory freed once the init function finishes for built-in drivers, but not loadable modules. If you think about when the init function is invoked, this makes perfect sense. There is also an `__initdata` which works similarly to `__init` but for init variables rather than functions.

The `__exit` macro causes the omission of the function when the module is built into the kernel, and like `__init`, has no effect for loadable modules. Again, if you consider when the cleanup function runs, this makes complete sense; built-in drivers do not need a cleanup function, while loadable modules do.

### module information

To reference what license you’re using a macro is available called `MODULE_LICENSE`. This and a few other macros describing the information of a module.

We can use the command `modinfo` as follow, to see these module information:
```
$ modinfo hello.ko
filename:       /root/kernel-lab/tutorial/0x00_basic/hello.ko
description:    A simple kernel module.
author:         LKMPG
license:        GPL
depends:
retpoline:      Y
name:           hello
vermagic:       5.10.133 SMP mod_unload
```

## Simple Character Device Driver: chardev

A sample code for a character device driver is given in `chardev.c`, and you can quickly browse its code and comments to understand what a character device driver is. However, this tutorial should focus on the kernel pwn. In this chapter we've talked about the basics of how to read, compile and run kernel modules, so we won't go deeper to see the details of writing a character device driver.

If you have interest about that topic, please refer to [1](https://sysprog21.github.io/lkmpg/#character-device-drivers) or [2](https://linux-kernel-labs.github.io/refs/heads/master/labs/device_drivers.html) for more details.
