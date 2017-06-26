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

FROM ubuntu:xenial

MAINTAINER Joakim Nohlgård <joakim.nohlgard@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

# The following package groups will be installed:
# - upgrade all system packages to latest available version
# - native platform development and build system functionality (about 400 MB installed)
# - Cortex-M development (about 550 MB installed), through the gcc-arm-embedded PPA
# - MSP430 development (about 120 MB installed)
# - AVR development (about 110 MB installed)
# - LLVM/Clang build environment (about 125 MB installed)
# - x86 bare metal emulation (about 125 MB installed) (this pulls in all of X11)
# All apt files will be deleted afterwards to reduce the size of the container image.
# This is all done in a single RUN command to reduce the number of layers and to
# allow the cleanup to actually save space.
# Total size without cleaning is approximately 1.525 GB (2016-03-08)
# After adding the cleanup commands the size is approximately 1.497 GB
RUN \
    dpkg --add-architecture i386 >&2 && \
    echo 'Adding gcc-arm-embedded PPA' >&2 && \
    echo "deb http://ppa.launchpad.net/team-gcc-arm-embedded/ppa/ubuntu xenial main" \
     > /etc/apt/sources.list.d/gcc-arm-embedded.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys B4D03348F75E3362B1E1C2A1D1FAA6ECF64D33B0 && \
    echo 'Upgrading all system packages to the latest available versions' >&2 && \
    apt-get update && apt-get -y dist-upgrade \
    && echo 'Installing native toolchain and build system functionality' >&2 && \
    apt-get -y install \
        bsdmainutils \
        build-essential \
        ccache \
        cmake \
        coccinelle \
        curl \
        cppcheck \
        doxygen \
        gcc-multilib \
        gdb \
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
        wget \
    && echo 'Installing Cortex-M toolchain' >&2 && \
    apt-get -y install \
        gcc-arm-embedded \
    && echo 'Installing MSP430 toolchain' >&2 && \
    apt-get -y install \
        gcc-msp430 \
    && echo 'Installing AVR toolchain' >&2 && \
    apt-get -y install \
        gcc-avr \
        binutils-avr \
        avr-libc \
    && echo 'Installing LLVM/Clang toolchain' >&2 && \
    apt-get -y install \
        llvm \
        clang \
    && echo 'Installing x86 bare metal emulation' >&2 && \
    apt-get -y install \
        qemu-system-x86 \
    && echo 'Installing socketCAN' >&2 && \
    apt-get -y install \
        libsocketcan-dev:i386 \
        libsocketcan2:i386 \
    && echo 'Cleaning up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install MIPS binary toolchain
RUN mkdir -p /opt && \
        wget -q http://codescape-mips-sdk.imgtec.com/components/toolchain/2016.05-03/Codescape.GNU.Tools.Package.2016.05-03.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz -O- \
        | tar -C /opt -xz

ENV PATH $PATH:/opt/mips-mti-elf/2016.05-03/bin
ENV MIPS_ELF_ROOT /opt/mips-mti-elf/2016.05-03

# compile suid create_user binary
COPY create_user.c /tmp/create_user.c
RUN gcc -DHOMEDIR=\"/data/riotbuild\" -DUSERNAME=\"riotbuild\" /tmp/create_user.c -o /usr/local/bin/create_user \
    && chown root:root /usr/local/bin/create_user \
    && chmod u=rws,g=x,o=- /usr/local/bin/create_user \
    && rm /tmp/create_user.c

# Create working directory for mounting the RIOT sources
RUN mkdir -m 777 -p /data/riotbuild

# Set a global system-wide git user and email address
RUN git config --system user.name "riot" && \
    git config --system user.email "riot@example.com"

# Copy our entry point script (signal wrapper)
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash", "/run.sh"]

# By default, run a shell when no command is specified on the docker command line
CMD ["/bin/bash"]

WORKDIR /data/riotbuild
