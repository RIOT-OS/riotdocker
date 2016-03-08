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

FROM ubuntu:wily

MAINTAINER Joakim Nohlgård <joakim.nohlgard@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

# arm-embedded toolchain PPA
RUN \
    echo "deb http://ppa.launchpad.net/team-gcc-arm-embedded/ppa/ubuntu wily main" \
     > /etc/apt/sources.list.d/gcc-arm-embedded.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys B4D03348F75E3362B1E1C2A1D1FAA6ECF64D33B0

# Fetch package repository and upgrade all system packages to latest available version
RUN apt-get update && apt-get -y dist-upgrade

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
RUN apt-get -y install \
    gcc-arm-embedded

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

# By default, run a shell when no command is specified on the docker command line
CMD ["/bin/bash"]

WORKDIR /data/riotbuild
