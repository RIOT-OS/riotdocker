#
# RIOT Dockerfile
#
# The resulting image will contain everything needed to build RIOT for all
# supported platforms. This is the largest build image, it takes about 1.5 GB in
# total.
#
# Setup:
# 1. Install docker, add yourself to docker group, enable docker, relogin
#
# Use prebuilt image:
# 1. Prebuilt image can be pulled from Docker Hub registry with:
#      # docker pull riot/riotbuild
#
# Use own build image:
# 1. Build own image based on latest base OS image (from the riotbuild directory):
#      # docker build --pull -t riotbuild .
#
# Usage:
# 1. cd to riot root
# 2. # docker run -i -t -u $UID -v $(pwd):/data/riotbuild riotbuild ./dist/tools/compile_test/compile_test.py
ARG DOCKER_REGISTRY="docker.io/riot"
FROM ${DOCKER_REGISTRY}/static-test-tools:latest

LABEL maintainer="Kaspar Schleiser <kaspar@riot-os.org>"

ENV DEBIAN_FRONTEND noninteractive

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# copy some included packages
RUN mkdir /pkgs
COPY files/libsocketcan-dev_0.0.11-1_i386.deb /pkgs/libsocketcan-dev_0.0.11-1_i386.deb
COPY files/libsocketcan2_0.0.11-1_i386.deb /pkgs/libsocketcan2_0.0.11-1_i386.deb

# The following package groups will be installed:
# - update the package index files to latest available version
# - native platform development and build system functionality (about 400 MB installed)
# - Cortex-M development (about 550 MB installed), through the gcc-arm-embedded PPA
# - MSP430 development (about 120 MB installed)
# - AVR development (about 110 MB installed)
# - LLVM/Clang build environment (about 125 MB installed)
# - QEMU
# All apt files will be deleted afterwards to reduce the size of the container image.
# The OS must not be updated by apt. Docker image should be build against the latest
#  updated base OS image. This can be forced with `--pull` flag.
# This is all done in a single RUN command to reduce the number of layers and to
# allow the cleanup to actually save space.
# Total size without cleaning is approximately 1.525 GB (2016-03-08)
# After adding the cleanup commands the size is approximately 1.497 GB
ARG LLVM_VERSION=14
RUN \
    dpkg --add-architecture i386 >&2 && \
    echo 'Update the package index files to latest available versions' >&2 && \
    apt-get update \
    && echo 'Installing native toolchain and build system functionality' >&2 && \
    apt-get -y --no-install-recommends install \
        afl++ \
        automake \
        bsdmainutils \
        build-essential \
        ca-certificates \
        ccache \
        cmake \
        curl \
        cython3 \
        gcc-multilib \
        gdb \
        g++-multilib \
        libffi-dev \
        libpcre3 \
        libtool \
        libsdl2-dev:i386 \
        m4 \
        ninja-build \
        parallel \
        protobuf-compiler \
        python2 \
        python3-setuptools \
        python3-venv \
        python3-wheel \
        p7zip \
        qemu-system-arm \
        rsync \
        socat \
        ssh-client \
        subversion \
        unzip \
        vim-common \
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
        llvm-${LLVM_VERSION} \
        clang-${LLVM_VERSION} \
        clang-tools-${LLVM_VERSION} \
        lld-${LLVM_VERSION} \
        llvm \
        clang \
        clang-tools \
    && echo 'Installing C2Rust (build) dependencies' >&2 && \
    apt-get -y --no-install-recommends install \
        libclang-dev \
        libssl-dev \
        llvm-dev \
        && \
    SYMS=$(find /usr/bin -type l) && \
    for file in ${SYMS}; do \
        SYMTARGET=$(readlink -f ${file}) && \
        SYMNAME=${file%"-${LLVM_VERSION}"} && \
        # Filter by symlinks starting with /usr/bin/llvm-${LLVM_VERSION}
        case "${SYMTARGET}" in "/usr/lib/llvm-${LLVM_VERSION}"* ) ln -sf ${SYMTARGET} ${SYMNAME}; esac \
    done \
    && echo 'Installing additional packages required for ESP32 toolchain' >&2 && \
    apt-get -y --no-install-recommends install \
        python3-serial \
        libpython2.7 \
        telnet \
    && echo 'Installing local packages' >&2 && \
    apt-get install -y --no-install-recommends /pkgs/*.deb \
    && echo 'Cleaning up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /pkgs

# Install ARM GNU embedded toolchain
# For updates, see https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads
ARG ARM_URLBASE=https://developer.arm.com/-/media/Files/downloads/gnu-rm
ARG ARM_URL=${ARM_URLBASE}/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
ARG ARM_MD5=2383e4eb4ea23f248d33adc70dc3227e
ARG ARM_FOLDER=gcc-arm-none-eabi-10.3-2021.10
RUN echo 'Installing arm-none-eabi toolchain from arm.com' >&2 && \
    mkdir -p /opt && \
    curl -L -o /opt/gcc-arm-none-eabi.tar.bz2 ${ARM_URL} && \
    echo "${ARM_MD5} /opt/gcc-arm-none-eabi.tar.bz2" | md5sum -c && \
    tar -C /opt -jxf /opt/gcc-arm-none-eabi.tar.bz2 && \
    rm -f /opt/gcc-arm-none-eabi.tar.bz2 && \
    echo 'Removing documentation' >&2 && \
    rm -rf /opt/gcc-arm-none-eabi-*/share/doc
    # No need to dedup, the ARM toolchain is already using hard links for the duplicated files

ENV PATH ${PATH}:/opt/${ARM_FOLDER}/bin

# Install MIPS binary toolchain
# For updates: https://www.mips.com/develop/tools/codescape-mips-sdk/ (select "Codescape GNU Toolchain")
ARG MIPS_VERSION=2020.06-01
RUN echo 'Installing mips-mti-elf toolchain from mips.com' >&2 && \
    mkdir -p /opt && \
    curl -L "https://codescape.mips.com/components/toolchain/${MIPS_VERSION}/Codescape.GNU.Tools.Package.${MIPS_VERSION}.for.MIPS.MTI.Bare.Metal.CentOS-6.x86_64.tar.gz" -o - \
        | tar -C /opt -zx && \
    echo 'Removing documentation and translations' >&2 && \
    rm -rf /opt/mips-mti-elf/*/share/{doc,info,man,locale} && \
    echo 'Deduplicating binaries' && \
    cd /opt/mips-mti-elf/*/mips-mti-elf/bin && \
    for f in *; do test -f "../../bin/mips-mti-elf-$f" && ln -f "../../bin/mips-mti-elf-$f" "$f"; done && cd -

ENV MIPS_ELF_ROOT /opt/mips-mti-elf/${MIPS_VERSION}

ENV PATH ${PATH}:${MIPS_ELF_ROOT}/bin

# Install RISC-V binary toolchain
ARG RISCV_VERSION=13.2.0-2
RUN mkdir -p /opt && \
        wget -q https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v${RISCV_VERSION}/xpack-riscv-none-elf-gcc-${RISCV_VERSION}-linux-x64.tar.gz -O- \
        | tar -C /opt -xz && \
    echo 'Removing documentation' >&2 && \
      rm -rf /opt/xpack-riscv-none-elf-gcc-${RISCV_VERSION}/share/doc && \
    echo 'Deduplicating binaries' >&2 && \
    cd /opt/xpack-riscv-none-elf-gcc-${RISCV_VERSION}/riscv-none-elf/bin && \
      for f in *; do test -f "../../bin/riscv-none-elf-$f" && \
       ln -f "../../bin/riscv-none-elf-$f" "$f"; \
      done && \
    cd -

ENV PATH $PATH:/opt/xpack-riscv-none-elf-gcc-${RISCV_VERSION}/bin

# Install complete ESP8266 toolchain in /opt/esp (139 MB after cleanup)
# remember https://github.com/RIOT-OS/RIOT/pull/10801 when updating
RUN echo 'Installing ESP8266 toolchain' >&2 && \
    mkdir -p /opt/esp && \
    cd /opt/esp && \
    git clone https://github.com/gschorcht/xtensa-esp8266-elf && \
    cd xtensa-esp8266-elf && \
    git checkout -q 696257c2b43e2a107d3108b2c1ca6d5df3fb1a6f && \
    rm -rf .git && \
    cd /opt/esp && \
    git clone https://github.com/gschorcht/RIOT-Xtensa-ESP8266-RTOS-SDK.git ESP8266_RTOS_SDK && \
    cd ESP8266_RTOS_SDK/ && \
    git checkout -q c0174eff7278eb5beea66ce1f65b7af57432d2a9 && \
    rm -rf .git* docs examples Kconfig make README.md tools && \
    cd components && \
    rm -rf app_update aws_iot bootloader cjson coap espos esptool_py esp-tls \
           freertos jsmn libsodium log mdns mqtt newlib partition_table \
           pthread smartconfig_ack spiffs ssl tcpip_adapter vfs && \
    find . -type f -name '*.[csS]' -exec rm {} \; && \
    find . -type f -name '*.cpp' -exec rm {} \;

ENV PATH $PATH:/opt/esp/xtensa-esp8266-elf/bin
ENV ESP8266_RTOS_SDK_DIR /opt/esp/ESP8266_RTOS_SDK

# Install ESP32 toolchain in /opt/esp (338 MB)
ARG ESP32_GCC_RELEASE="esp-12.2.0_20230208"
ARG ESP32_GCC_VERSION="12.2.0_20230208"
ARG ESP32_GCC_REPO=https://github.com/espressif/crosstool-NG/releases/download
ARG ESP32_GCC_FILE=xtensa-esp32-elf-${ESP32_GCC_VERSION}-x86_64-linux-gnu.tar.xz
ARG ESP32_GCC_URL=${ESP32_GCC_REPO}/${ESP32_GCC_RELEASE}/${ESP32_GCC_FILE}

RUN echo 'Installing ESP32 toolchain' >&2 && \
    curl -L ${ESP32_GCC_URL} | tar -C /opt/esp -xJ && \
    pip install --no-cache-dir pyserial
ENV PATH $PATH:/opt/esp/xtensa-esp32-elf/bin

# Install ESP32 QEMU in /opt/esp (130 MB)
ARG ESP32_QEMU_VERSION="esp-develop-20220203"
ARG ESP32_QEMU_REPO=https://github.com/espressif/qemu/releases/download
ARG ESP32_QEMU_FILE=qemu-${ESP32_QEMU_VERSION}.tar.bz2
ARG ESP32_QEMU_URL=${ESP32_QEMU_REPO}/${ESP32_QEMU_VERSION}/${ESP32_QEMU_FILE}

RUN echo 'Installing ESP32 QEMU' >&2 && \
    curl -L ${ESP32_QEMU_URL} | tar -C /opt/esp -xj
ENV PATH $PATH:/opt/esp/qemu/bin

# Install ESP32-C3 toolchain in /opt/esp (859 MB)
ARG ESP32_GCC_FILE=riscv32-esp-elf-${ESP32_GCC_VERSION}-x86_64-linux-gnu.tar.xz
ARG ESP32_GCC_URL=${ESP32_GCC_REPO}/${ESP32_GCC_RELEASE}/${ESP32_GCC_FILE}

RUN echo 'Installing ESP32-C3 toolchain' >&2 && \
    curl -L ${ESP32_GCC_URL} | tar -C /opt/esp -xJ
ENV PATH $PATH:/opt/esp/riscv32-esp-elf/bin

# Install ESP32-S2 toolchain in /opt/esp (340 MB)
ARG ESP32_GCC_FILE=xtensa-esp32s2-elf-${ESP32_GCC_VERSION}-x86_64-linux-gnu.tar.xz
ARG ESP32_GCC_URL=${ESP32_GCC_REPO}/${ESP32_GCC_RELEASE}/${ESP32_GCC_FILE}

RUN echo 'Installing ESP32-S2 toolchain' >&2 && \
    curl -L ${ESP32_GCC_URL} | tar -C /opt/esp -xJ
ENV PATH $PATH:/opt/esp/xtensa-esp32s2-elf/bin

# Install ESP32-S3 toolchain in /opt/esp (341 MB)
ARG ESP32_GCC_FILE=xtensa-esp32s3-elf-${ESP32_GCC_VERSION}-x86_64-linux-gnu.tar.xz
ARG ESP32_GCC_URL=${ESP32_GCC_REPO}/${ESP32_GCC_RELEASE}/${ESP32_GCC_FILE}

RUN echo 'Installing ESP32-S3 toolchain' >&2 && \
    curl -L ${ESP32_GCC_URL} | tar -C /opt/esp -xJ
ENV PATH $PATH:/opt/esp/xtensa-esp32s3-elf/bin

# Install GDB for Xtensa base ESP32 x SoCs in /opt/esp (94 MB)
ARG ESP32_GDB_VERSION=12.1_20221002
ARG ESP32_GDB_REPO=https://github.com/espressif/binutils-gdb/releases/download
ARG ESP32_GDB_REPO_DIR=esp-gdb-v${ESP32_GDB_VERSION}
ARG ESP32_GDB_FILE=xtensa-esp-elf-gdb-${ESP32_GDB_VERSION}-x86_64-linux-gnu.tar.gz
ARG ESP32_GDB_URL=${ESP32_GDB_REPO}/${ESP32_GDB_REPO_DIR}/${ESP32_GDB_FILE}

RUN echo 'Installing GDB for Xtensa based ESP32x SoCs' >&2 && \
    curl -L ${ESP32_GDB_URL} | tar -C /opt/esp -xz
ENV PATH $PATH:/opt/esp/xtensa-esp-elf-gdb/bin

# Install GDB for RISC-V based ESP32 SoCs in /opt/esp (93 MB)
ARG ESP32_GDB_FILE=riscv32-esp-elf-gdb-${ESP32_GDB_VERSION}-x86_64-linux-gnu.tar.gz
ARG ESP32_GDB_URL=${ESP32_GDB_REPO}/${ESP32_GDB_REPO_DIR}/${ESP32_GDB_FILE}

RUN echo 'Installing GDB for RISC-V based ESP32x SoCs' >&2 && \
    curl -L ${ESP32_GDB_URL} | tar -C /opt/esp -xz
ENV PATH $PATH:/opt/esp/riscv32-esp-elf-gdb/bin

ARG PICOLIBC_REPO=https://github.com/keith-packard/picolibc
ARG PICOLIBC_TAG=1.4.6
ARG PICOLIBC_URL=${PICOLIBC_REPO}/archive/${PICOLIBC_TAG}.tar.gz
ARG PICOLIBC_ARCHIVE=${PICOLIBC_TAG}.tar.gz

RUN echo 'Building and Installing PicoLIBC' >&2 && \
    pip3 install --no-cache-dir meson && \
    mkdir -p /usr/src/picolibc && \
    cd /usr/src/picolibc/ &&\
    curl -L -o ${PICOLIBC_ARCHIVE} ${PICOLIBC_URL} && \
    tar -xf ${PICOLIBC_ARCHIVE} && \
    cd picolibc-${PICOLIBC_TAG}

COPY cross-riscv-none-elf.txt /usr/src/picolibc/picolibc-${PICOLIBC_TAG}/

RUN cd /usr/src/picolibc/picolibc-${PICOLIBC_TAG} && \
    which riscv-none-elf-gcc && \
    ls -al /opt/xpack-riscv-none-elf-gcc-${RISCV_VERSION}/bin && \
    mkdir build-arm build-riscv build-esp32 && \
    cd build-riscv && \
    meson .. -Dtests=true -Dmultilib=false -Dincludedir=picolibc/riscv-none-elf/include -Dlibdir=picolibc/riscv-none-elf/lib --cross-file ../cross-riscv-none-elf.txt && \
    ninja && ninja install && \
    cd ../build-esp32 && \
    sh ../do-esp32-configure && \
    ninja && ninja install && \
    cd ../build-arm && \
    sh ../do-arm-configure && \
    ninja && ninja install

# No need to keep the sources around
RUN rm -rf /usr/src/picolibc

# RIOT toolchains
ARG RIOT_TOOLCHAIN_GCC_VERSION=10.1.0
ARG RIOT_TOOLCHAIN_PACKAGE_VERSION=18
ARG RIOT_TOOLCHAIN_TAG=20200722112854-64162e7
ARG RIOT_TOOLCHAIN_GCCPKGVER=${RIOT_TOOLCHAIN_GCC_VERSION}-${RIOT_TOOLCHAIN_PACKAGE_VERSION}
ARG RIOT_TOOLCHAIN_SUBDIR=${RIOT_TOOLCHAIN_GCCPKGVER}-${RIOT_TOOLCHAIN_TAG}

ARG MSP430_URL=https://github.com/RIOT-OS/toolchains/releases/download/${RIOT_TOOLCHAIN_SUBDIR}/riot-msp430-elf-${RIOT_TOOLCHAIN_GCCPKGVER}.tgz
RUN echo 'Installing RIOT MSP430 ELF toolchain' >&2 && \
        wget -q ${MSP430_URL} -O- | tar -C /opt -xz
ENV PATH $PATH:/opt/riot-toolchain/msp430-elf/${RIOT_TOOLCHAIN_GCCPKGVER}/bin

# install required python packages from file
# numpy must be already installed before installing some other requirements (emlearn)
RUN pip3 install --no-cache-dir numpy==1.22.4
COPY requirements.txt /tmp/requirements.txt
RUN echo 'Installing python3 packages' >&2 \
    && pip3 install --no-cache-dir pybind11 \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# While sourcing ~/.cargo/env later would have the right short-term effect,
# we'd still need to set the right path even later when HOME is
# /data/riotbuild -- so setting it right away.
ENV PATH ${PATH}:/opt/rustup/.cargo/bin
# Install nightly Rust via rustup; this is needed for Rust-on-RIOT builds and
# contains all CARGO_TARGETs currently recognized for RIOT targets.
#
# *_HOMEs moved to /opt to make them world readable. RUSTUP_HOME is set
# persistently in case someone in their image wants to do a quick `sudo rustup
# toolchain add` or similar; CARGO_HOME is not because the user will need to
# write there, and all rustup does here is to place some binaries that later
# fan out to RUSTUP_HOME anyway.
#
# Components: rust-src is needed to run `-Z build-std=core`, which in turn is
# needed on AVR (which thus doesn't need the avr-unknown-gnu-atmega328 target;
# being able to build core might be useful for other targets as well).
ENV RUSTUP_HOME /opt/rustup/.rustup
RUN \
    RUSTUP_HOME=/opt/rustup/.rustup \
    CARGO_HOME=/opt/rustup/.cargo sh -c "\
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal && \
    rustup component add rust-src && \
    rustup target add i686-unknown-linux-gnu && \
    rustup target add riscv32imac-unknown-none-elf && \
    rustup target add thumbv7em-none-eabihf && \
    rustup target add thumbv7em-none-eabi && \
    rustup target add thumbv7m-none-eabi && \
    rustup target add thumbv6m-none-eabi && \
    rustup target add thumbv8m.main-none-eabihf && \
    rustup target add thumbv8m.main-none-eabi && \
    rustup target add thumbv8m.base-none-eabi && \
    true"

RUN \
    echo 'Installing C2Rust' >&2 && \
    CARGO_HOME=/opt/rustup/.cargo cargo install --no-track --locked c2rust --git https://github.com/chrysn-pull-requests/c2rust --branch riscv-vector-types && \
    echo 'Cleaning up root-owned crates.io cache' >&2 && \
    rm -rf /opt/rustup/.cargo/{git,registry,.package-cache}

# get laze binary
COPY --from=kaspar030/laze:0.1.20-jammy /laze /usr/bin/laze

# get Dockerfile version from build args
ARG RIOTBUILD_VERSION=unknown
ENV RIOTBUILD_VERSION $RIOTBUILD_VERSION

ARG RIOTBUILD_COMMIT=unknown
ENV RIOTBUILD_COMMIT $RIOTBUILD_COMMIT

ARG RIOTBUILD_BRANCH=unknown
ENV RIOTBUILD_BRANCH $RIOTBUILD_BRANCH

# watch for single ">" vs double ">>"!
RUN echo "RIOTBUILD_VERSION=$RIOTBUILD_VERSION" > /etc/riotbuild
RUN echo "RIOTBUILD_COMMIT=$RIOTBUILD_COMMIT" >> /etc/riotbuild
RUN echo "RIOTBUILD_BRANCH=$RIOTBUILD_BRANCH" >> /etc/riotbuild
