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

FROM ubuntu:bionic

MAINTAINER Joakim Nohlgård <joakim.nohlgard@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

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
    echo 'Upgrading all system packages to the latest available versions' >&2 && \
    apt-get update && apt-get -y dist-upgrade \
    && echo 'Installing native toolchain and build system functionality' >&2 && \
    apt-get -y --no-install-recommends install \
        automake \
        bsdmainutils \
        build-essential \
        ca-certificates \
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
        less \
        libpcre3 \
        libtool \
        m4 \
        parallel \
        pcregrep \
        python \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        p7zip \
        rsync \
        ssh-client \
        subversion \
        unzip \
        vera++ \
        vim-common \
        wget \
        xsltproc \
    && echo 'Installing MSP430 toolchain' >&2 && \
    apt-get -y --no-install-recommends install \
        gcc-msp430 \
        msp430-libc \
    && echo 'Installing AVR toolchain' >&2 && \
    apt-get -y --no-install-recommends install \
        gcc-avr \
        binutils-avr \
        avr-libc \
    && echo 'Installing LLVM/Clang toolchain' >&2 && \
    apt-get -y --no-install-recommends install \
        llvm \
        clang \
        clang-tools \
    && echo 'Installing socketCAN' >&2 && \
    apt-get -y --no-install-recommends install \
        libsocketcan-dev:i386 \
        libsocketcan2:i386 \
    && echo 'Cleaning up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install ARM GNU embedded toolchain
# For updates, see https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads
RUN echo 'Installing arm-none-eabi toolchain from arm.com' >&2 && \
    mkdir -p /opt && \
    curl -L -o /opt/gcc-arm-none-eabi.tar.bz2 'https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2?revision=bc2c96c0-14b5-4bb4-9f18-bceb4050fee7?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,7-2018-q2-update' && \
    echo '299ebd3f1c2c90930d28ab82e5d8d6c0 */opt/gcc-arm-none-eabi.tar.bz2' | md5sum -c && \
    tar -C /opt -jxf /opt/gcc-arm-none-eabi.tar.bz2 && \
    rm -f /opt/gcc-arm-none-eabi.tar.bz2 && \
    echo 'Removing documentation' >&2 && \
    rm -rf /opt/gcc-arm-none-eabi-*/share/doc
    # No need to dedup, the ARM toolchain is already using hard links for the duplicated files

ENV PATH ${PATH}:/opt/gcc-arm-none-eabi-7-2018-q2-update/bin

# Install MIPS binary toolchain
# For updates: https://www.mips.com/develop/tools/codescape-mips-sdk/ (select "Codescape GNU Toolchain")
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
ARG RISCV_VERSION=8.2.0-2.2-20190521
ARG RISCV_BUILD=0004
RUN mkdir -p /opt && \
        wget -q https://github.com/gnu-mcu-eclipse/riscv-none-gcc/releases/download/v${RISCV_VERSION}/gnu-mcu-eclipse-riscv-none-gcc-${RISCV_VERSION}-${RISCV_BUILD}-centos64.tgz -O- \
        | tar -C /opt -xz && \
    echo 'Removing documentation' >&2 && \
      rm -rf /opt/gnu-mcu-eclipse/riscv-none-gcc/*/share/doc && \
    echo 'Deduplicating binaries' >&2 && \
    cd /opt/gnu-mcu-eclipse/riscv-none-gcc/*/riscv-none-embed/bin && \
      for f in *; do test -f "../../bin/riscv-none-embed-$f" && \
       ln -f "../../bin/riscv-none-embed-$f" "$f"; \
      done && \
    cd -

ENV PATH $PATH:/opt/gnu-mcu-eclipse/riscv-none-gcc/${RISCV_VERSION}-${RISCV_BUILD}/bin

# compile suid create_user binary
COPY create_user.c /tmp/create_user.c
RUN gcc -DHOMEDIR=\"/data/riotbuild\" -DUSERNAME=\"riotbuild\" /tmp/create_user.c -o /usr/local/bin/create_user \
    && chown root:root /usr/local/bin/create_user \
    && chmod u=rws,g=x,o=- /usr/local/bin/create_user \
    && rm /tmp/create_user.c

# Install complete ESP8266 toolchain in /opt/esp (146 MB after cleanup)
RUN echo 'Installing ESP8266 toolchain' >&2 && \
    cd /opt && \
    git clone https://github.com/gschorcht/RIOT-Xtensa-ESP8266-toolchain.git esp && \
    cd esp && \
    git checkout -q df38b06 && \
    rm -rf .git

ENV PATH $PATH:/opt/esp/esp-open-sdk/xtensa-lx106-elf/bin

# Install ESP32 toolchain in /opt/esp (181 MB after cleanup)
# remember https://github.com/RIOT-OS/RIOT/pull/10801 when updating
RUN echo 'Installing ESP32 toolchain' >&2 && \
    mkdir -p /opt/esp && \
    cd /opt/esp && \
    git clone https://github.com/espressif/esp-idf.git && \
    cd esp-idf && \
    git checkout -q f198339ec09e90666150672884535802304d23ec && \
    git submodule update --init --recursive && \
    rm -rf .git* docs examples make tools && \
    rm -f add_path.sh CONTRIBUTING.rst Kconfig Kconfig.compiler && \
    cd components && \
    rm -rf app_trace app_update aws_iot bootloader bt coap console cxx \
           esp_adc_cal espcoredump esp_http_client esp-tls expat fatfs \
           freertos idf_test jsmn json libsodium log lwip mbedtls mdns \
           micro-ecc nghttp openssl partition_table pthread sdmmc spiffs \
           tcpip_adapter ulp vfs wear_levelling xtensa-debug-module && \
    find . -name '*.[csS]' -exec rm {} \; && \
    cd /opt/esp && \
    git clone https://github.com/gschorcht/xtensa-esp32-elf.git && \
    cd xtensa-esp32-elf && \
    git checkout -q ca40fb4c219accf8e7c8eab68f58a7fc14cadbab

ENV PATH $PATH:/opt/esp/xtensa-esp32-elf/bin

# Install msp430-elf-gcc
# see https://aur.archlinux.org/packages/msp430-elf-gcc

ENV MSP430_GCC_BINUTILS_VER=2.32
ENV MSP430_GCC_BINUTILS_SHA=0ab6c55dd86a92ed561972ba15b9b70a8b9f75557f896446c82e8b36e473ee04
RUN mkdir -p /mspgcc && \
    cd /mspgcc && \
    curl -o binutils-${MSP430_GCC_BINUTILS_VER}.tar.xz ftp://ftp.gnu.org/gnu/binutils/binutils-${MSP430_GCC_BINUTILS_VER}.tar.xz && \
    echo "$MSP430_GCC_BINUTILS_SHA binutils-${MSP430_GCC_BINUTILS_VER}.tar.xz" | sha256sum -c - && \
    tar xJf binutils-${MSP430_GCC_BINUTILS_VER}.tar.xz && \
    cd /mspgcc/binutils-$MSP430_GCC_BINUTILS_VER && \
    mkdir binutils-build && \
    cd binutils-build && \
    ../configure --target=msp430-elf \
      --prefix=/usr \
      --disable-nls \
      --program-prefix=msp430-elf- \
      --enable-multilib \
      --disable-werror \
      --with-sysroot=/usr/msp430-elf \
      --host=$CHOST \
      --build=$CHOST \
      --disable-shared \
      --enable-lto && \
    make configure-host && \
    make && \
    make install && \
    rm -rf /mspgcc/binutils-${MSP430_GCC_BINUTILS_VER}.tar.xz /mspgcc/binutils-$MSP430_GCC_BINUTILS_VER

ENV MSP430_GCC_VER=9.2.0
ENV MSP430_GCC_SHA=ea6ef08f121239da5695f76c9b33637a118dcf63e24164422231917fa61fb206
ENV MSP430_GCC_ISL_VER=0.21
ENV MSP430_GCC_ISL_SHA=777058852a3db9500954361e294881214f6ecd4b594c00da5eee974cd6a54960

# dependencies
RUN apt-get update && \
    apt-get -y --no-install-recommends install libmpc-dev zlib1g-dev && \
    echo 'Cleaning up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# download isl sources
RUN mkdir -p /mspgcc && \
    cd /mspgcc && \
    curl -o isl-${MSP430_GCC_ISL_VER}.tar.xz http://isl.gforge.inria.fr/isl-${MSP430_GCC_ISL_VER}.tar.xz && \
    echo "$MSP430_GCC_ISL_SHA isl-$MSP430_GCC_ISL_VER.tar.xz" | sha256sum -c - && \
    tar xJf isl-${MSP430_GCC_ISL_VER}.tar.xz

# download gcc sources
RUN mkdir -p /mspgcc && \
    cd /mspgcc && \
    curl -o gcc-${MSP430_GCC_VER}.tar.xz ftp://gcc.gnu.org/pub/gcc/releases/gcc-${MSP430_GCC_VER}/gcc-${MSP430_GCC_VER}.tar.xz && \
    echo "$MSP430_GCC_SHA gcc-$MSP430_GCC_VER.tar.xz" | sha256sum -c - && \
    tar xJf gcc-${MSP430_GCC_VER}.tar.xz

# compile bootstrapping gcc compiler
RUN CFLAGS="-O2 -pipe" CXXFLAGS="-O2 -pipe" CFLAGS_FOR_TARGET="-Os -pipe" CXXFLAGS_FOR_TARGET="-Os -pipe" cd /mspgcc/gcc-$MSP430_GCC_VER && \
    ln -s ../isl-$MSP430_GCC_ISL_VER isl  && \
    echo $MSP430_GCC_VER > gcc/BASE-VER && \
    mkdir -p gcc-build && \
    ls -ahl && \
    cd gcc-build && \
    ../configure \
      --prefix=/usr \
      --program-prefix=msp430-elf- \
      --target=msp430-elf \
      --host=$CHOST \
      --build=$CHOST \
      --disable-shared \
      --disable-nls \
      --disable-threads \
      --enable-languages=c \
      --enable-multilib \
      --without-headers \
      --with-newlib \
      --with-system-zlib \
      --with-local-prefix=/usr/msp430-elf \
      --with-sysroot=/usr/msp430-elf \
      --with-as=/usr/bin/msp430-elf-as \
      --with-ld=/usr/bin/msp430-elf-ld \
      --disable-libgomp && \
    make all-gcc && \
    make install-gcc

# install newlib for msp430
ENV MSP430_GCC_NEWLIB_VER=3.1.0
ENV MSP430_GCC_NEWLIB_SHA=fb4fa1cc21e9060719208300a61420e4089d6de6ef59cf533b57fe74801d102a
RUN CFLAGS_FOR_TARGET="-Os -g -ffunction-sections -fdata-sections" mkdir -p /mspgcc && \
    cd /mspgcc && \
    curl -o newlib-${MSP430_GCC_NEWLIB_VER}.tar.gz ftp://sourceware.org/pub/newlib/newlib-${MSP430_GCC_NEWLIB_VER}.tar.gz && \
    echo "$MSP430_GCC_NEWLIB_SHA newlib-${MSP430_GCC_NEWLIB_VER}.tar.gz" | sha256sum -c - && \
    tar xzf newlib-${MSP430_GCC_NEWLIB_VER}.tar.gz && \
    cd /mspgcc/newlib-${MSP430_GCC_NEWLIB_VER} && \
    mkdir newlib-build && \
    cd newlib-build && \
    ../configure \
     --prefix=/usr \
     --target=msp430-elf \
     --disable-newlib-supplied-syscalls \
     --enable-newlib-reent-small \
     --disable-newlib-fseek-optimization \
     --disable-newlib-wide-orient \
     --enable-newlib-nano-formatted-io \
     --disable-newlib-io-float \
     --enable-newlib-nano-malloc \
     --disable-newlib-unbuf-stream-opt \
     --enable-lite-exit \
     --enable-newlib-global-atexit \
     --disable-nls && \
   make -j1 && \
   make install && \
   mkdir -p /usr/msp430-elf/usr && \
   ln -sf /usr/msp430-elf/include /usr/msp430-elf/usr/include && \
   ln -sf /usr/msp430-elf/lib /usr/msp430-elf/usr/lib && \
   rm -rf /mspgcc/newlib-${MSP430_GCC_NEWLIB_VER}.tar.gz /mspgcc/newlib-${MSP430_GCC_NEWLIB_VER}

# install msp430-elf-gcc, final version
RUN cd /mspgcc/gcc-$MSP430_GCC_VER && \
    ln -s ../isl-$MSP430_GCC_ISL_VER isl  && \
    echo $MSP430_GCC_VER > gcc/BASE-VER && \
    rm -rf gcc-build && \
    mkdir -p gcc-build && \
    ls -ahl && \
    cd gcc-build && \
    ../configure \
      --prefix=/usr \
      --program-prefix=msp430-elf- \
      --target=msp430-elf \
      --host=$CHOST \
      --build=$CHOST \
      --disable-shared \
      --disable-nls \
      --disable-threads \
      --enable-languages=c,c++ \
      --enable-multilib \
      --with-system-zlib \
      --with-local-prefix=/usr/msp430-elf \
      --with-sysroot=/usr/msp430-elf \
      --with-as=/usr/bin/msp430-elf-as \
      --with-ld=/usr/bin/msp430-elf-ld \
      --disable-libgomp \
      --disable-libssp \
      --enable-interwork \
      --enable-addons && \
    make all-gcc all-target-libgcc && \
    make install-gcc install-target-libgcc && \
    rm -rf /mspgcc

ENV MSP430_GCC_SUPPORT_VER=1.207
ENV MSP430_GCC_SUPPORT_MD5=27b6a533378a901be96efb896714b0ec

# download msp430 headers
RUN mkdir -p /mspgcc && \
    cd /mspgcc && \
    curl -L -o msp430-gcc-support-files-${MSP430_GCC_SUPPORT_VER}.zip http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/latest/exports/msp430-gcc-support-files-${MSP430_GCC_SUPPORT_VER}.zip && \
    echo "$MSP430_GCC_SUPPORT_MD5 msp430-gcc-support-files-${MSP430_GCC_SUPPORT_VER}.zip" | md5sum -c - && \
    unzip msp430-gcc-support-files-${MSP430_GCC_SUPPORT_VER}.zip && \
    cd msp430-gcc-support-files/include && \
    install -dm755 "/usr/msp430-elf/lib" && \
    install -m644 *.ld "/usr/msp430-elf/lib" && \
    install -dm755 "/usr/msp430-elf/include" && \
    install -m644 *.h "/usr/msp430-elf/include" && \
    install -dm755 "/usr/msp430-elf/include/devices" && \
    install -m644 devices.csv "/usr/msp430-elf/include/devices" && \
    rm -rf /mspgcc

# install required python packages from file
COPY requirements.txt /tmp/requirements.txt
RUN echo 'Installing python3 packages' >&2 \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

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
