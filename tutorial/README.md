# How to use this tutorial?

## Prerequisites

Please make sure you have docker and docker-compose installed correctly. If you haven't, you can refer to [Install Docker Engine](https://docs.docker.com/engine/install/) and [Install Docker Compose](https://docs.docker.com/compose/install/) to learn how to install them.

## Getting your own kernel hacking environment

I have prepared a Dockerfile that you can use it to build an image that will provide the environment needed to compile and debug the kernel. So, first of all, you need to build a docker image as follows:
```
$ docker-compose build
```

After the image build process finished, you can run the following command to start a container and execute an interactive shell in it to access your own kernel hacking environment:
```
$ docker-compose up -d
$ docker-compose exec kernel-lab /bin/bash
```

Since we will be handling multiple tasks in the container, such as compiling the kernel, starting the virtual machine, debugging the kernel, reading the code, etc. Therefore, it is very helpful to use tmux to manage tasks under multiple screens. You can use the following command to start a tmux session:
```
$ tmux new -s lab
```
And you can get more tips on using tmux from: [Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started).

## Compiling kernel

Now that things are ready, we can start downloading the source code for a particular version of the kernel and compiling it. First, we can use `script/kernel.sh` to download the kernel source.

```
$ ./script/kernel.sh
--2022-07-31 06:32:45--  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.133.tar.xz
Connecting to cdn.kernel.org (cdn.kernel.org)|151.101.193.176|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 120457796 (115M) [application/x-xz]
Saving to: ‘/opt/lab/.cache/kernel/v5.x/linux-5.10.133.tar.xz’

linux-5.10.133.tar.xz                                               100%[===================================================================================================================================================================>] 114.88M  2.13MB/s    in 77s

2022-07-31 06:34:08 (1.49 MB/s) - ‘/opt/lab/.cache/kernel/v5.x/linux-5.10.133.tar.xz’ saved [120457796/120457796]

--2022-07-31 06:34:08--  https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.133.tar.sign
Connecting to cdn.kernel.org (cdn.kernel.org)|151.101.193.176|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 993 [text/plain]
Saving to: ‘/opt/lab/.cache/kernel/v5.x/linux-5.10.133.tar.sign’

linux-5.10.133.tar.sign                                             100%[===================================================================================================================================================================>]     993  --.-KB/s    in 0s

2022-07-31 06:34:09 (30.7 MB/s) - ‘/opt/lab/.cache/kernel/v5.x/linux-5.10.133.tar.sign’ saved [993/993]
```

As you can see, the default version we downloaded is 5.10.133, which is specified in `script/kernel.sh` by variable `KERNEL_VERSION`, and you can change it into any kernel version you want to download. After downloading, we can visit the directory `/opt/lab/.cache/kernel/v5.x/` and extract `linux-5.10.133.tar.xz` to get the kernel source code. (If you are an extremely security-conscious person, perhaps you can verify the gpg signature before extracting it.)

```
$ cd /opt/lab/.cache/kernel/v5.x/ && tar -xf linux-5.10.133.tar.xz
```

We've got the kernel source code, so now we can go into the source directory, run `make menuconfig` to customize the kernel configuration:

```
$ cd /opt/lab/.cache/kernel/v5.x/linux-5.10.133/ && make menuconfig
```

Note that in order to debug the kernel, it is a good idea to open the kernel's debug symbol configuration, which is located in the following directory hierarchy in the kernel configure menu:

```
Kernel hacking ->
    Compile-time checks and compiler options ->
        [x] Compile the kernel with debug info
```

Finally, let's start compiling the kernel:

```
$ make -j $(nproc)
```

## Building the root filesystem 

It is not enough to only have a kernel, we also need a root filesystem to interact with our kernel as a user space. In most of the tutorials, they build the root filesystem based on busybox. But this solution has some problems, for example, it can be very difficult to install new tools (you need to rebuild the image file and reboot the system to remount it). So in this tutorial, we will try another solution, using `debootstrap` to build a debian-like root filesystem. It will be very powerful, just like you are using a debian distribution, and you can easily install a new tool by using the apt command.

The good news is that this is very simple, you just need to run the `script/rootfs.sh` and it will do everything for you to create a debian-like root filesystem. The only thing you need to do while the script is running is to set a password for your root account which will be used later to log in to the system.

```
$ ./script/rootfs.sh
Formatting '/opt/lab/debian.img', fmt=raw size=68719476736
mke2fs 1.46.5 (30-Dec-2021)
Discarding device blocks: done
Creating filesystem with 16777216 4k blocks and 4194304 inodes
Filesystem UUID: 35e6bcb8-9a0e-44ce-847a-2e525cbceaad
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000, 7962624, 11239424

Allocating group tables: done
Writing inode tables: done
Creating journal (131072 blocks): done
Writing superblocks and filesystem accounting information: done

......

[*] Please set the root password for your virtaul machine!
New password:
Retype new password:
passwd: password updated successfully
[*] Generate /opt/lab/debian.qcow2.
```

## Starting your virtual machine

Now you can start your virtual machine by running `script/debian.sh`.

```
$ ./script/debian.sh
```

You may see the command frozen in terminal, that is because qemu's kernel debugging feature is triggered as soon as the VM starts and it will wait for you using a debugger to attach it. To solve this probelem, we can access port 23 using the telnet client, and the qemu monitor listens to this port by default with our custom settings. We can execute the c (continue) command in the qemu monitor, which will tell the VM to stop hanging and continue the boot process.

```
$ telnet 127.0.0.1 23
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
QEMU 6.2.0 monitor - type 'help' for more information
(qemu) c
c
(qemu)
```

After booting for a while, you will see a login screen as follows:

```
[  OK  ] Started Serial Getty on ttyS0.
[  OK  ] Reached target Login Prompts.
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.
         Starting Update UTMP about System Runlevel Changes...
[  OK  ] Finished Update UTMP about System Runlevel Changes.

Debian GNU/Linux 11 4a8d43a71da0 ttyS0

4a8d43a71da0 login:
```

You just need to enter the password you set when creating the root filesystem and you will see a login success message and a shell prompt.

```
[  OK  ] Started Serial Getty on ttyS0.
[  OK  ] Reached target Login Prompts.
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.
         Starting Update UTMP about System Runlevel Changes...
[  OK  ] Finished Update UTMP about System Runlevel Changes.

Debian GNU/Linux 11 4a8d43a71da0 ttyS0

4a8d43a71da0 login: root
Password:
Linux 4a8d43a71da0 5.10.133 #1 SMP Sun Jul 31 08:00:49 UTC 2022 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
root@4a8d43a71da0:~#
```

Now you can execute some commands to test if the system is running well. It is recommended to execute the following commands to install openssh-server.

```
$ apt update && apt install -y openssh-server
```

That is because the virtual machine's ssh port (22) is mapped to the container's port 22, so if openssh-server is installed, we can easily access the virtual machine in the container via the ssh protocol. It will be very helpful when we test kernel modules or transfer files between containers and VMs.

```
$ ssh root@127.0.0.1
The authenticity of host '127.0.0.1 (127.0.0.1)' can't be established.
ED25519 key fingerprint is SHA256:/ZZqroQ34+EiNdLPxhy2EKeu2GNyEZyf3WFzhHniXFM.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '127.0.0.1' (ED25519) to the list of known hosts.
root@127.0.0.1's password:
Permission denied, please try again.
root@127.0.0.1's password:
Permission denied, please try again.
root@127.0.0.1's password:
root@127.0.0.1: Permission denied (publickey,password).
```

You may encounter an error as the one shown above. It is due to the default configuration(`/etc/ssh/sshd_config`) of ssh which does not allow the root user to log in with a password. So you need to execute the following command to solve this issue.

```
$ echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
$ systemctl restart sshd
```

Congratulations, if you have arrived here, it means that you have successfully booted your virtaul machine. All the preparations are done, let's start the kernel hacking journey.
