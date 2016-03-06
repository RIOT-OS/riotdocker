#
# RIOT Dockerfile
#
# the resulting image will contain everything needed to build RIOT for all
# supported platforms. This is the largest build image, it takes about 1.5 GB in
# total.
#
# Setup: (only needed once per Dockerfile change)
# 1. install docker, add yourself to docker group, enable docker, relogin
# 2. # docker build -t riotbuild .
#
# Usage:
# 3. cd to riot root
# 4. # docker run -i -t -u $UID -v $(pwd):/data/riotbuild riotbuild ./dist/tools/compile_test/compile_test.py

# Ubuntu 14.04 requires a third-party PPA (terry.guo/gcc-arm-embedded below) for
# Cortex-M development, at least for a fully functional newlib and stdlibc++.
#FROM ubuntu:trusty # Ubuntu 14.04
# Debian wheezy (stable) is also lacking proper newlib and stdlibc++ for arm-none-eabi.

# The below base images do not need any extra PPAs for building any RIOT platform.
# Ubuntu 14.10
#FROM ubuntu:utopic
# Ubuntu 15.04
#FROM ubuntu:vivid
# same as jessie?
#FROM debian:testing
# same as testing?
FROM debian:jessie
# Debian unstable
#FROM debian:sid
# probably not a good idea to use this for your build needs.
#FROM debian:experimental

MAINTAINER Joakim Nohlgård <joakim.nohlgard@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

# For Ubuntu 14.04 only:
#RUN echo "deb http://ppa.launchpad.net/terry.guo/gcc-arm-embedded/ubuntu trusty main" > /etc/apt/sources.list.d/gcc-arm-embedded.list
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key FE324A81C208C89497EFC6246D1D8367A3421AFB
# You may need to specify the exact version of gcc-arm-none-eabi to install
# below, or else the old Debian version might get pulled in.
# Also, remove libnewlib-arm-none-eabi and libstdc++-arm-none-eabi-newlib from
# the install command below if using the above PPA as the gcc package has
# everything included.

# Add backports repository for gcc-arm-none-eabi 4.9 on jessie
# Fetch package repository and upgrade all system packages to latest available version
RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' > \
    /etc/apt/sources.list.d/backports.list && \
    apt-get update && apt-get -y dist-upgrade

# native platform development and build system functionality (about 400 MB installed)
RUN apt-get -y install \
    bsdmainutils \
    build-essential \
    cmake \
    curl \
    cppcheck \
    doxygen \
    gcc-multilib \
    g++-multilib \
    git \
    graphviz \
    libpcre3 \
    parallel \
    pcregrep \
    python \
    python3 \
    python3-pexpect \
    p7zip \
    subversion \
    unzip \
    wget

# Cortex-M development (about 550 MB installed)
RUN apt-get -t jessie-backports -y install \
    binutils-arm-none-eabi \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    libnewlib-dev

# MSP430 development (about 120 MB installed)
RUN apt-get -y install \
    gcc-msp430

# AVR development (about 110 MB installed)
RUN apt-get -y install \
    gcc-avr \
    binutils-avr \
    avr-libc

# LLVM/Clang build environment (about 125 MB installed)
RUN apt-get -y install \
    llvm \
    clang

# x86 bare metal emulation (about 125 MB installed) (this pulls in all of X11)
RUN apt-get -y install \
    qemu-system-x86

# Create working directory for mounting the RIOT sources
RUN mkdir -p /data/riotbuild

# Set a global system-wide git user and email address
RUN git config --system user.name "riot" && \
    git config --system user.email "riot@example.com"

# Copy our entry point script (signal wrapper)
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash", "/run.sh"]

WORKDIR /data/riotbuild
