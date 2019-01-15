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
        lsb-release \
        m4 \
        parallel \
        pcregrep \
        python \
        python3 \
        python3-dev \
        python3-pip \
        p7zip \
        rsync \
        ssh-client \
        subversion \
        unzip \
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

# install required python packages from file
COPY install_requirements.txt /tmp/install_requirements.txt
COPY requirements.txt /tmp/requirements.txt
RUN echo 'Installing python3 packages' >&2 \
    && pip3 install --no-cache-dir -r /tmp/install_requirements.txt \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && pip3 uninstall -y -r /tmp/install_requirements.txt \
    && rm /tmp/install_requirements.txt \
    && rm /tmp/requirements.txt

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
RUN mkdir -p /opt && \
        wget -q https://github.com/gnu-mcu-eclipse/riscv-none-gcc/releases/download/v7.2.0-2-20180110/gnu-mcu-eclipse-riscv-none-gcc-7.2.0-2-20180111-2230-centos64.tgz -O- \
        | tar -C /opt -xz && \
    echo 'Removing documentation' >&2 && \
    rm -rf /opt/gnu-mcu-eclipse/riscv-none-gcc/*/share/doc && \
    echo 'Deduplicating binaries' >&2 && \
    cd /opt/gnu-mcu-eclipse/riscv-none-gcc/*/riscv-none-embed/bin && \
    for f in *; do rm "$f" && ln "../../bin/riscv-none-embed-$f" "$f"; done && cd -

# HACK download arch linux' flex dynamic library
RUN wget -q https://sgp.mirror.pkgbuild.com/core/os/x86_64/flex-2.6.4-2-x86_64.pkg.tar.xz -O- \
        | tar -C / -xJ usr/lib/libfl.so.2.0.0
RUN ldconfig

ENV PATH $PATH:/opt/gnu-mcu-eclipse/riscv-none-gcc/7.2.0-2-20180111-2230/bin

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
RUN echo 'Installing ESP32 toolchain' >&2 && \
    mkdir -p /opt/esp && \
    cd /opt/esp && \
    git clone --recursive https://github.com/espressif/esp-idf.git && \
    cd esp-idf && \
    git checkout -q f198339ec09e90666150672884535802304d23ec && \
    cd components/esp32/lib && \
    git checkout -q 534a9b14101af90231d40a4f94924d67bc848d5f && \
    cd /opt/esp/esp-idf && \
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
