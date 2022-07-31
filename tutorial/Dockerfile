FROM ubuntu:22.04

MAINTAINER zengxian.thomas@gmail.com

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y qemu-system qemu-user-static debootstrap
RUN apt-get install -y build-essential gdb python3 python3-pip
RUN apt-get install -y libncurses5-dev flex bison libelf-dev libssl-dev bc
RUN apt-get install -y tmux wget telnet openssh-client file locales

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && dpkg-reconfigure --frontend=noninteractive locales

RUN python3 -m pip install --upgrade pip
RUN bash -c "$(wget https://gef.blah.cat/sh -O -)"

WORKDIR /opt/lab
