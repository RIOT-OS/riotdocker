#!/bin/bash

# Automatically exit on error
set -e

COUNTER_STEP=0
COUNTER_SUBSTEP=0
BLUE="\e[34m"
BOLD="\e[1m"
NORMAL="\e[0m"

LLVM_VERSION=${LLVM_VERSION:-14}

ARM_VERSION=${ARM_VERSION:-10.3-2021.10}
ARM_SHA256=${ARM_SHA256:-97dbb4f019ad1650b732faffcc881689cedc14e2b7ee863d390e0a41ef16c9a3}
ARM_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/${ARM_VERSION}/gcc-arm-none-eabi-${ARM_VERSION}-x86_64-linux.tar.bz2"
ARM_FOLDER="gcc-arm-none-eabi-$ARM_VERSION"

RISCV_VERSION=${RISCV_VERSION:-12.2.0-3}
RISCV_SHA256=${RISCV_SHA256:-0bb5f0c6a36f5197888fcd176e3734ec5b74167b5a631883f72ae3cbd47a97c3}
RISCV_URL="https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v${RISCV_VERSION}/xpack-riscv-none-elf-gcc-${RISCV_VERSION}-linux-x64.tar.gz"
RISCV_FOLDER="xpack-riscv-none-elf-gcc-$RISCV_VERSION"

ESP8266_REPO=${ESP8266_REPO:-https://github.com/gschorcht/xtensa-esp8266-elf}
ESP8266_COMMIT=${ESP8266_COMMIT:-696257c2b43e2a107d3108b2c1ca6d5df3fb1a6f}
ESP8266_RTOS_SDK_REPO=${ESP8266_RTOS_SDK_REPO:-https://github.com/gschorcht/RIOT-Xtensa-ESP8266-RTOS-SDK.git}
ESP8266_RTOS_SDK_COMMIT=${ESP8266_RTOS_SDK_COMMIT:-c0174eff7278eb5beea66ce1f65b7af57432d2a9}

ESP32_GCC_RELEASE="${ESP32_GCC_RELEASE:-esp-2021r2-patch3}"
ESP32_GCC_VERSION="${ESP32_GCC_VERSION:-gcc8_4_0}"
ESP32_GCC_SHA256="${ESP32_GCC_SHA256:-9edd1e77627688f435561922d14299f6a0021ba1f6ff67e472e1108695a69e53}"
ESP32_GCC_REPO="https://github.com/espressif/crosstool-NG/releases/download"
ESP32_GCC_FILE="xtensa-esp32-elf-${ESP32_GCC_VERSION}-${ESP32_GCC_RELEASE}-linux-amd64.tar.gz"
ESP32_GCC_URL="${ESP32_GCC_REPO}/${ESP32_GCC_RELEASE}/${ESP32_GCC_FILE}"

ESP32_C3_GCC_SHA256="${ESP32_C3_GCC_SHA256:-179cbad579790ad35e0f414a18d90017c0f158c397022411a8e9867db2174f15}"
ESP32_C3_GCC_FILE="riscv32-esp-elf-${ESP32_GCC_VERSION}-${ESP32_GCC_RELEASE}-linux-amd64.tar.gz"
ESP32_C3_GCC_URL="${ESP32_GCC_REPO}/${ESP32_GCC_RELEASE}/${ESP32_C3_GCC_FILE}"

ESP32_S2_GCC_SHA256="${ESP32_S2_GCC_SHA256:-a32451a8edc1104b83cd9971178e61826e957d7db9ad9f81798a8969fd5a954e}"
ESP32_S2_GCC_FILE="xtensa-esp32s2-elf-${ESP32_GCC_VERSION}-${ESP32_GCC_RELEASE}-linux-amd64.tar.gz"
ESP32_S2_GCC_URL="${ESP32_GCC_REPO}/${ESP32_GCC_RELEASE}/${ESP32_S2_GCC_FILE}"

ESP32_S3_GCC_SHA256="${ESP32_S3_GCC_SHA256:-59b271d014ff3915b6db1b43b610a45eea15fe5d6877d12cae8a191cc996ed37}"
ESP32_S3_GCC_FILE="xtensa-esp32s3-elf-${ESP32_GCC_VERSION}-${ESP32_GCC_RELEASE}-linux-amd64.tar.gz"
ESP32_S3_GCC_URL="${ESP32_GCC_REPO}/${ESP32_GCC_RELEASE}/${ESP32_S3_GCC_FILE}"

ESP32_QEMU_VERSION="${ESP32_QEMU_VERSION:-esp-develop-20220203}"
ESP32_QEMU_SHA256="${ESP32_QEMU_SHA256:-c83e483e3290f48a563c2a376b7413cd94a8692d8c7308b119f4268ca6d164b6}"
ESP32_QEMU_REPO="https://github.com/espressif/qemu/releases/download"
ESP32_QEMU_FILE="qemu-${ESP32_QEMU_VERSION}.tar.bz2"
ESP32_QEMU_URL="${ESP32_QEMU_REPO}/${ESP32_QEMU_VERSION}/${ESP32_QEMU_FILE}"

RIOT_TOOLCHAIN_GCC_VERSION="${RIOT_TOOLCHAIN_GCC_VERSION:-10.1.0}"
RIOT_TOOLCHAIN_PACKAGE_VERSION="${RIOT_TOOLCHAIN_PACKAGE_VERSION:-18}"
RIOT_TOOLCHAIN_TAG="${RIOT_TOOLCHAIN_TAG:-20200722112854-64162e7}"
RIOT_TOOLCHAIN_GCCPKGVER="${RIOT_TOOLCHAIN_GCC_VERSION}-${RIOT_TOOLCHAIN_PACKAGE_VERSION}"
RIOT_TOOLCHAIN_SUBDIR="${RIOT_TOOLCHAIN_GCCPKGVER}-${RIOT_TOOLCHAIN_TAG}"

MSP430_URL="https://github.com/RIOT-OS/toolchains/releases/download/${RIOT_TOOLCHAIN_SUBDIR}/riot-msp430-elf-${RIOT_TOOLCHAIN_GCCPKGVER}.tgz"
MSP430_SHA256="${MSP430_SHA256:-ff10de6fd4567557a1cf61e7c16b55a6a21edb9800afe89c2228c19da3a32b0f}"

PICOLIBC_TAG="${PICOLIBC_TAG:-1.8}"
PICOLIBC_SHA256="${PICOLIBC_SHA256:-cad52d2b690a22d00aa8486234a1df24136828b469e6b5328c171ebcf610f382}"
PICOLIBC_REPO="https://github.com/keith-packard/picolibc"
PICOLIBC_URL="${PICOLIBC_REPO}/releases/download/$PICOLIBC_TAG/picolibc-$PICOLIBC_TAG.tar.xz"

step() {
    COUNTER_SUBSTEP=0
    COUNTER_STEP=$(("$COUNTER_STEP" + 1))
    printf "${BLUE}${BOLD}==>${NORMAL}${BOLD} Step %d:${NORMAL} %s\n" "$COUNTER_STEP" "$1"
}

substep() {
    COUNTER_SUBSTEP=$(("$COUNTER_SUBSTEP" + 1))
    printf "${BLUE}${BOLD}    -->${NORMAL}${BOLD} Step %d.%d:${NORMAL} %s\n" \
        "$COUNTER_STEP" "$COUNTER_SUBSTEP" "$1"
}

git_shallow_clone_commit() {
    local url
    local commit
    local folder
    local oldfolder
    url="$1"
    commit="$2"
    folder="${3:-$(basename "$url")}"
    oldfolder="$(pwd)"
    mkdir -p "$folder"
    cd "$folder"
    git init
    git remote add origin "$url"
    git fetch --depth 1 origin "$commit"
    git checkout FETCH_HEAD
    cd "$oldfolder"
}

step_prepare_apt() {
    step "Updating apt package index"
    dpkg --add-architecture i386
    apt-get update
}

step_install_apt_packages() {
    step "Installing packages via apt package manager"

    substep "Installing shell tools"
    apt-get -y --no-install-recommends install \
        bsdmainutils \
        curl \
        m4 \
        p7zip \
        parallel \
        rsync \
        socat \
        ssh-client \
        unzip \
        vim-common \
        xsltproc

    substep "Installing python stuff"
    apt-get -y --no-install-recommends install \
        cython3 \
        python2 \
        python3-setuptools \
        python3-wheel

    substep "Installing generic development tools and libs"
    apt-get -y --no-install-recommends install \
        afl++ \
        automake \
        build-essential \
        ca-certificates \
        ccache \
        cmake \
        gdb \
        libffi-dev \
        libpcre3 \
        libtool \
        meson\
        ninja-build \
        protobuf-compiler

    substep "Installing 32 bit support for native"
    apt-get -y --no-install-recommends install \
        gcc-multilib \
        g++-multilib \
        libsdl2-dev:i386

    substep "Installing qemu for ARM"
    apt-get -y --no-install-recommends install \
        qemu-system-arm

    substep "Installing AVR toolchain"
    apt-get -y --no-install-recommends install \
        gcc-avr \
        binutils-avr \
        avr-libc

    substep "Installing LLVM/Clang toolchain"
    apt-get -y --no-install-recommends install \
        llvm-"${LLVM_VERSION}" \
        clang-"${LLVM_VERSION}" \
        clang-tools-"${LLVM_VERSION}" \
        lld-"${LLVM_VERSION}" \
        llvm \
        clang \
        clang-tools

    substep "Installing C2Rust (build) dependencies"
    apt-get -y --no-install-recommends install \
        libclang-dev \
        libssl-dev \
        llvm-dev

    substep "Installing symlinks for LLVM tools without version postfix"
    SYMS="$(find /usr/bin -type l)"
    for file in ${SYMS}; do
        SYMTARGET="$(readlink -f "${file}")"
        SYMNAME="${file%"-${LLVM_VERSION}"}"
        # Filter by symlinks starting with /usr/bin/llvm-${LLVM_VERSION}
        case "${SYMTARGET}" in
         "/usr/lib/llvm-${LLVM_VERSION}"*)
            ln -sf "${SYMTARGET}" "${SYMNAME}"
            ;;
        esac
    done

    substep "Installing additional packages required for ESP32 toolchain"
    apt-get -y --no-install-recommends install \
        python3-serial \
        libpython2.7 \
        telnet

    substep "Installing local packages"
    apt-get install -y --no-install-recommends ./*.deb
}

step_install_arm_toolchain() {
    step "Installing arm-none-eabi toolchain from arm.com"

    substep "Downloading and verifying binary distribution"
    mkdir -p /opt
    curl -L -o /opt/gcc-arm-none-eabi.tar.bz2 "${ARM_URL}"
    echo "${ARM_SHA256} /opt/gcc-arm-none-eabi.tar.bz2" | sha256sum -c -

    substep "Unpacking binaries"
    tar -C /opt -jxf /opt/gcc-arm-none-eabi.tar.bz2
    rm -f /opt/gcc-arm-none-eabi.tar.bz2

    substep "Removing documentation"
    rm -rf /opt/"$ARM_FOLDER"/share/doc

    substep "Relocating folder to stable path"
    mv /opt/"$ARM_FOLDER" /opt/arm-none-eabi
}

step_install_riscv_toolchain() {
    step "Installing xPack GNU RISC-V Embedded GCC"

    substep "Downloading and verifying binary distribution"
    mkdir -p /opt
    curl -L -o /opt/gcc-riscv-none-elf.tar.gz "${RISCV_URL}"
    echo "${RISCV_SHA256} /opt/gcc-riscv-none-elf.tar.gz" | sha256sum -c -

    substep "Unpacking binaries"
    tar -C /opt -xf /opt/gcc-riscv-none-elf.tar.gz
    rm -f /opt/gcc-riscv-none-elf.tar.gz

    substep "Removing documentation"
    rm -rf /opt/"$RISCV_FOLDER"/share/doc

    substep "Relocating folder to stable path"
    mv /opt/"$RISCV_FOLDER" /opt/riscv-none-elf
}

step_install_esp8266_toolchain() {
    step "Installing ESP8266 toolchain"

    substep "Cloning toolchain repo"
    git_shallow_clone_commit "$ESP8266_REPO" "$ESP8266_COMMIT" \
        /opt/esp/xtensa-esp8266-elf

    substep "Cloning RTOS SDK repo"
    git_shallow_clone_commit "$ESP8266_RTOS_SDK_REPO" "$ESP8266_RTOS_SDK_COMMIT" \
        /opt/esp/ESP8266_RTOS_SDK

    substep "Removing .git from both repos"
    rm -rf /opt/esp/xtensa-esp8266-elf/.git
    rm -rf /opt/esp/ESP8266_RTOS_SDK/.git

    substep "Removing unneeded SDK files"
    for item in docs examples Kconfig make README.md tools; do
        rm -rf "/opt/esp/ESP8266_RTOS_SDK/$item"
    done

    for component in app_update aws_iot bootloader cjson coap espos esptool_py esp-tls \
           freertos jsmn libsodium log mdns mqtt newlib partition_table \
           pthread smartconfig_ack spiffs ssl tcpip_adapter vfs; do
        rm -rf "/opt/esp/ESP8266_RTOS_SDK/components/$component"
    done
    find "/opt/esp/ESP8266_RTOS_SDK/components" -type f -name '*.[csS]' -exec rm {} \;
    find "/opt/esp/ESP8266_RTOS_SDK/components" -type f -name '*.cpp' -exec rm {} \;
}

step_install_esp32_toolchain() {
    step "Installing ESP32 toolchain"

    substep "Downloading and verifying xtensa-esp32-elf toolchain"
    mkdir -p /opt
    curl -L -o /opt/xtensa-esp32-elf.tar.gz "${ESP32_GCC_URL}"
    echo "${ESP32_GCC_SHA256} /opt/xtensa-esp32-elf.tar.gz" | sha256sum -c -

    substep "Unpacking xtensa-esp32-elf toolchain"
    tar -C /opt/esp -xf /opt/xtensa-esp32-elf.tar.gz
    rm -f /opt/xtensa-esp32-elf.tar.gz
}

step_install_esp32_c3_toolchain() {
    step "Installing ESP32-C3 toolchain"

    substep "Downloading and verifying riscv32-esp-elf toolchain"
    mkdir -p /opt
    curl -L -o /opt/riscv32-esp-elf.tar.gz "${ESP32_C3_GCC_URL}"
    echo "${ESP32_C3_GCC_SHA256} /opt/riscv32-esp-elf.tar.gz" | sha256sum -c -

    substep "Unpacking riscv32-esp-elf toolchain"
    tar -C /opt/esp -xf /opt/riscv32-esp-elf.tar.gz
    rm -f /opt/riscv32-esp-elf.tar.gz
}

step_install_esp32_s2_toolchain() {
    step "Installing ESP32-S2 toolchain"

    substep "Downloading and verifying xtensa-esp32s2-elf toolchain"
    mkdir -p /opt
    curl -L -o /opt/xtensa-esp32s2-elf.tar.gz "${ESP32_S2_GCC_URL}"
    echo "${ESP32_S2_GCC_SHA256} /opt/xtensa-esp32s2-elf.tar.gz" | sha256sum -c -

    substep "Unpacking xtensa-esp32s2-elf toolchain"
    tar -C /opt/esp -xf /opt/xtensa-esp32s2-elf.tar.gz
    rm -f /opt/xtensa-esp32s2-elf.tar.gz
}

step_install_esp32_s3_toolchain() {
    step "Installing ESP32-S3 toolchain"

    substep "Downloading and verifying xtensa-esp32s3-elf toolchain"
    mkdir -p /opt
    curl -L -o /opt/xtensa-esp32s3-elf.tar.gz "${ESP32_S3_GCC_URL}"
    echo "${ESP32_S3_GCC_SHA256} /opt/xtensa-esp32s3-elf.tar.gz" | sha256sum -c -

    substep "Unpacking xtensa-esp32s3-elf toolchain"
    tar -C /opt/esp -xf /opt/xtensa-esp32s3-elf.tar.gz
    rm -f /opt/xtensa-esp32s3-elf.tar.gz
}

step_install_esp32_qemu() {
    step "Installing ESP32 QEMU"

    substep "Downloading and verifying archive"
    mkdir -p /opt
    curl -L -o /opt/qemu-esp32.tar.gz "${ESP32_QEMU_URL}"
    echo "${ESP32_QEMU_SHA256} /opt/qemu-esp32.tar.gz" | sha256sum -c -

    substep "Unpacking archive"
    tar -C /opt/esp -xf /opt/qemu-esp32.tar.gz
    rm -f /opt/qemu-esp32.tar.gz
}

step_install_msp430_toolchain() {
    step "Installing MSP430 toolchain"

    substep "Downloading and verifying msp430-elf toolchain"
    mkdir -p /opt
    curl -L -o /opt/msp430.tgz "${MSP430_URL}"
    echo "${MSP430_SHA256} /opt/msp430.tgz" | sha256sum -c -

    substep "Unpacking archive"
    tar -C /opt/ -xf /opt/msp430.tgz
    rm -f /opt/msp430.tgz

    substep "Relocating folder to stable path"
    mv /opt/riot-toolchain/msp430-elf/"$RIOT_TOOLCHAIN_GCCPKGVER" \
       /opt/msp430-elf
    rmdir /opt/riot-toolchain/msp430-elf
    rmdir /opt/riot-toolchain
}


step_install_picolibc() {
    local olddir
    olddir="$(pwd)"
    step "Installing picolibc"

    substep "Downloading and verifying archive"
    curl -L -o /tmp/picolibc.tar.xz "${PICOLIBC_URL}"
    echo "${PICOLIBC_SHA256} /tmp/picolibc.tar.xz" | sha256sum -c -

    substep "Unpacking source"
    tar -C /tmp/ -xf /tmp/picolibc.tar.xz

    substep "Building picolibc for ARM"
    mkdir -p /tmp/picolibc-arm
    cd /tmp/picolibc-arm
    sh /tmp/picolibc-"$PICOLIBC_TAG"/scripts/do-arm-configure
    ninja
    ninja install

    substep "Building picolibc for riscv-none-elf"
    # patching mismatch in target triple
    cp /tmp/picolibc-"$PICOLIBC_TAG"/scripts/cross-riscv64-unknown-elf.txt \
       /tmp/picolibc-"$PICOLIBC_TAG"/scripts/cross-riscv-none-elf.txt
    sed -e 's/riscv64-unknown-elf/riscv-none-elf/g' \
        -i /tmp/picolibc-"$PICOLIBC_TAG"/scripts/cross-riscv-none-elf.txt \
        -i /tmp/picolibc-"$PICOLIBC_TAG"/scripts/do-riscv-configure
    # patching mismatch in ISA spec between binutils and GCC
    sed -e "s/c = \['riscv-none-elf-gcc'/c = \['riscv-none-elf-gcc', '-misa-spec=2.2'/" \
        -i /tmp/picolibc-"$PICOLIBC_TAG"/scripts/cross-riscv-none-elf.txt
    mkdir -p /tmp/picolibc-riscv
    cd /tmp/picolibc-riscv
    sh /tmp/picolibc-"$PICOLIBC_TAG"/scripts/do-riscv-configure
    ninja
    ninja install

    substep "Building picolibc for xtensa-esp32-elf"
    # patching incorrect cpu family
    sed -e "s/cpu_family = 'esp32'/cpu_family = 'xtensa'/" \
        -i /tmp/picolibc-"$PICOLIBC_TAG"/scripts/cross-xtensa-esp32-elf.txt
    mkdir -p /tmp/picolibc-esp32
    cd /tmp/picolibc-esp32
    sh /tmp/picolibc-"$PICOLIBC_TAG"/scripts/do-esp32-configure
    ninja
    ninja install

    substep "Building picolibc for msp430-elf"
    mkdir -p /tmp/picolibc-msp430
    cd /tmp/picolibc-msp430
    sh /tmp/picolibc-"$PICOLIBC_TAG"/scripts/do-msp430-configure
    ninja
    ninja install

    substep "Removing picolibc source and build files again"
    rm -rf /tmp/picolibc*

    cd "$olddir"
}

step_install_pip_packages() {
    step "Installing python packages with pip"

    substep "Installing numpy first; this is required to be in place to be able to install emlearn"
    pip3 install --no-cache-dir numpy==1.22.4

    substep "Installing pybind11 for undocumented reasons separately as well"
    pip3 install --no-cache-dir pybind11

    substep "Installing remaining python3 packages from requirements.txt"
    pip3 install --no-cache-dir -r requirements.txt
}

step_install_rust_toolchains() {
    step "Installing rust toolchains"

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
    export RUSTUP_HOME=/opt/rustup/.rustup
    export CARGO_HOME=/opt/rustup/.cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain nightly-2022-09-25
    rustup toolchain add stable
    for toolchain in nightly-2022-09-25 stable; do
        substep "Installing toolchain $toolchain for all supported architectures"
        rustup component add rust-src --toolchain "$toolchain"
        rustup target add i686-unknown-linux-gnu --toolchain "$toolchain"
        rustup target add riscv32imac-unknown-none-elf --toolchain "$toolchain"
        rustup target add thumbv7em-none-eabihf --toolchain "$toolchain"
        rustup target add thumbv7em-none-eabi --toolchain "$toolchain"
        rustup target add thumbv7m-none-eabi --toolchain "$toolchain"
        rustup target add thumbv6m-none-eabi --toolchain "$toolchain"
        rustup target add thumbv8m.main-none-eabihf --toolchain "$toolchain"
        rustup target add thumbv8m.main-none-eabi --toolchain "$toolchain"
        rustup target add thumbv8m.base-none-eabi --toolchain "$toolchain"
    done

    substep "Installing C2Rust"
    CARGO_HOME=/opt/rustup/.cargo cargo install --no-track --locked c2rust --git https://github.com/chrysn-pull-requests/c2rust --branch riscv-vector-types

    substep "Cleaning up root-owned crates.io cache"
    rm -rf /opt/rustup/.cargo/{git,registry,.package-cache}
}

step_riotbuild_version() {

    echo "RIOTBUILD_VERSION=$RIOTBUILD_VERSION" > /etc/riotbuild
    echo "RIOTBUILD_COMMIT=$RIOTBUILD_COMMIT" >> /etc/riotbuild
    echo "RIOTBUILD_BRANCH=$RIOTBUILD_BRANCH" >> /etc/riotbuild
}

step_clean_apt() {
    step "Cleaning up apt package index and temporary files"
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}

step_prepare_apt
step_install_apt_packages
step_install_arm_toolchain
step_install_riscv_toolchain
step_install_esp8266_toolchain
step_install_esp32_toolchain
step_install_esp32_c3_toolchain
step_install_esp32_s2_toolchain
step_install_esp32_s3_toolchain
step_install_esp32_qemu
step_install_msp430_toolchain
step_install_picolibc
step_install_pip_packages
step_install_rust_toolchains
step_riotbuild_version
step_clean_apt
exit 0
