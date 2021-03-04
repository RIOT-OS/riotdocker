ARG DOCKERHUB_REGISTRY="riot"
FROM ${DOCKERHUB_REGISTRY}/riotdocker-base

LABEL maintainer="francois-xavier.molina@inria.fr"

ARG FLASH_DEPS="make unzip wget"

ARG OPENOCD_INSTALL_DEPS="build-essential git ca-certificates libtool pkg-config autoconf automake texinfo \
                          libhidapi-hidraw0 libhidapi-dev libusb-1.0"
ARG OPENOCD_VERSION=5f3bc3b279c648f5c751fcd4724206c6ce3e38c6
ARG OPENOCD_DEPS=""

# Upgrading system packages to the latest available versions
RUN apt-get update && apt-get -y dist-upgrade
# Installing required packages for flashing toolchain
RUN apt-get -y --no-install-recommends install \
        ${OPENOCD_INSTALL_DEPS} \
        ${OPENOCD_DEPS} \
        ${FLASH_DEPS} \
    # Cleaning up installation files
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Build openocd from source
RUN mkdir -p opt \
    && cd /opt \
    && git clone --depth 1 git://git.code.sf.net/p/openocd/code openocd\
    && cd openocd \
    && git checkout -q ${OPENOCD_VERSION} \
    && ./bootstrap \
    && ./configure --enable-stlink --enable-jlink --enable-ftdi --enable-cmsis-dap \
    && make -j"$(nproc)" \
    && make install-strip \
    && cd .. \
    && rm -rf openocd \
    && rm -rf /var/lib/apt/lists/*
