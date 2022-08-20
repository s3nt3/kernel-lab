FROM ubuntu:22.04

MAINTAINER zengxian.thomas@gmail.com

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y qemu-system qemu-user-static debootstrap
RUN apt-get install -y build-essential gdb python3 python3-pip
RUN apt-get install -y libncurses5-dev flex bison libelf-dev libssl-dev bc
RUN apt-get install -y file cscope exuberant-ctags
RUN apt-get install -y tmux locales

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && dpkg-reconfigure --frontend=noninteractive locales

RUN apt-get install -y sudo
RUN apt-get install -y zsh git

WORKDIR /opt
RUN git clone --depth=1 https://github.com/pwndbg/pwndbg

WORKDIR /opt/pwndbg
RUN sed -i "s/^git submodule/#git submodule/" ./setup.sh && \
    DEBIAN_FRONTEND=noninteractive ./setup.sh

RUN git submodule update --init --recursive

RUN echo "source /pwndbg/gdbinit.py" >> ~/.gdbinit.py && \
    echo "PYTHON_MINOR=\$(python3 -c \"import sys;print(sys.version_info.minor)\")" >> /root/.bashrc && \
    echo "PYTHON_PATH=\"/usr/local/lib/python3.\${PYTHON_MINOR}/dist-packages/bin\"" >> /root/.bashrc && \
    echo "export PATH=\$PATH:\$PYTHON_PATH" >> /root/.bashrc

RUN echo "set auto-load safe-path /root/.cache/kernel-lab/kernel" >> /root/.gdbinit

RUN apt-get install -y wget telnet openssh-client
RUN apt-get install -y neovim python3-neovim

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install pwntools
RUN python3 -m pip install ROPgadget

WORKDIR /root/kernel-lab

