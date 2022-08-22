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
RUN apt-get install -y zsh git wget

# If you'd like to use pwndbg, please uncomment following lines:
#
# WORKDIR /opt
# RUN git clone --depth=1 https://github.com/pwndbg/pwndbg
# 
# WORKDIR /opt/pwndbg
# RUN sed -i "s/^git submodule/#git submodule/" ./setup.sh && \
#     DEBIAN_FRONTEND=noninteractive ./setup.sh
# 
# RUN git submodule update --init --recursive
# 
# RUN echo "source /pwndbg/gdbinit.py" >> ~/.gdbinit.py && \
#     echo "PYTHON_MINOR=\$(python3 -c \"import sys;print(sys.version_info.minor)\")" >> /root/.zshrc && \
#     echo "PYTHON_PATH=\"/usr/local/lib/python3.\${PYTHON_MINOR}/dist-packages/bin\"" >> /root/.zshrc && \
#     echo "export PATH=\$PATH:\$PYTHON_PATH" >> /root/.zshrc

# Use gef as default gdb enhancement script
RUN bash -c "$(wget https://gef.blah.cat/sh -O -)"
RUN echo "set auto-load safe-path /root/.cache/kernel-lab/kernel" >> /root/.gdbinit

RUN apt-get install -y telnet openssh-client
RUN apt-get install -y neovim python3-neovim

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install pwntools
RUN python3 -m pip install ropper

# Install oh-my-zsh
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

WORKDIR /root/kernel-lab

