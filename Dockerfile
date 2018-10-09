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
        automake \
        bsdmainutils \
        build-essential \
        ccache \
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
        libtool \
        m4 \
        parallel \
        pcregrep \
        python \
        python3 \
        python3-pexpect \
        python3-crypto \
        python3-pyasn1 \
        python3-ecdsa \
        python3-flake8 \
        p7zip \
        subversion \
        unzip \
        vim-common \
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
    && echo 'Installing socketCAN' >&2 && \
    apt-get -y install \
        libsocketcan-dev:i386 \
        libsocketcan2:i386 \
    && echo 'Cleaning up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install CMake 3.10
RUN wget -q https://cmake.org/files/v3.10/cmake-3.10.0.tar.gz -O- \
    | tar -C /tmp -xz && cd /tmp/cmake-3.10.0/ && ./bootstrap && \
    make && make install && cd && rm -rf /tmp/cmake-3.10.0

# Install MIPS binary toolchain
RUN mkdir -p /opt && \
        wget -q https://codescape.mips.com/components/toolchain/2016.05-03/Codescape.GNU.Tools.Package.2016.05-03.for.MIPS.MTI.Bare.Metal.CentOS-5.x86_64.tar.gz -O- \
        | tar -C /opt -xz && \
    echo 'Removing documentation and translations' >&2 && \
    rm -rf /opt/mips-mti-elf/*/share/{doc,info,man,locale} && \
    echo 'Deduplicating binaries' >&2 && \
    cd /opt/mips-mti-elf/*/mips-mti-elf/bin && \
    for f in *; do rm "$f" && ln "../../bin/mips-mti-elf-$f" "$f"; done && cd -

ENV MIPS_ELF_ROOT /opt/mips-mti-elf/2016.05-03
ENV PATH ${PATH}:${MIPS_ELF_ROOT}/bin

# Install RISC-V binary toolchain
RUN mkdir -p /opt && \
        wget -q https://github.com/gnu-mcu-eclipse/riscv-none-gcc/releases/download/v7.2.0-2-20180110/gnu-mcu-eclipse-riscv-none-gcc-7.2.0-2-20180111-2230-centos64.tgz -O- \
        | tar -C /opt -xz && \
    echo 'Removing documentation' >&2 && \
    rm -rf /opt/gnu-mcu-eclipse/riscv-none-gcc/*/share/doc && \
    echo 'Deduplicating binaries' >&2 && \
    cd /opt/gnu-mcu-eclipse/riscv-none-gcc/*/riscv-none-embed/bin && \
    for f in *; do rm "$f" && ln "../../bin/riscv-none-embed-$f" "$f"; done && cd -

# HACK download arch linux' flex dynamic library
RUN wget -q https://sgp.mirror.pkgbuild.com/core/os/x86_64/flex-2.6.4-1-x86_64.pkg.tar.xz -O- \
        | tar -C / -xJ usr/lib/libfl.so.2.0.0
RUN ldconfig

ENV PATH $PATH:/opt/gnu-mcu-eclipse/riscv-none-gcc/7.2.0-2-20180111-2230/bin

# compile suid create_user binary
COPY create_user.c /tmp/create_user.c
RUN gcc -DHOMEDIR=\"/data/riotbuild\" -DUSERNAME=\"riotbuild\" /tmp/create_user.c -o /usr/local/bin/create_user \
    && chown root:root /usr/local/bin/create_user \
    && chmod u=rws,g=x,o=- /usr/local/bin/create_user \
    && rm /tmp/create_user.c

# Installs the complete ESP8266 toolchain in /opt/esp (146 MB after cleanup) from binaries
RUN echo 'Adding esp8266 toolchain' >&2 && \
    cd /opt && \
    git clone https://github.com/gschorcht/RIOT-Xtensa-ESP8266-toolchain.git esp && \
    cd esp && \
    git checkout -q df38b06 && \
    rm -rf .git

ENV PATH $PATH:/opt/esp/esp-open-sdk/xtensa-lx106-elf/bin

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
