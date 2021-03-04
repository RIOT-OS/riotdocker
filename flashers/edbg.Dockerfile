ARG DOCKER_REGISTRY="riot"
FROM ubuntu:bionic AS builder

ARG EDBG_INSTALL_DEPS="git ca-certificates build-essential libudev-dev"
ARG EDBG_VERSION=47c6ba4f7e61b0cce1b724cb62692de6e26a0267

# Upgrading system packages to the latest available versions
RUN apt-get update && apt-get -y dist-upgrade
# Installing required packages for flashing toolchain
RUN apt-get -y --no-install-recommends install \
        ${EDBG_INSTALL_DEPS} \
    # Cleaning up installation files
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Compile edbg binary
RUN mkdir -p opt \
    && cd /opt \
    && git clone --depth 1 https://github.com/ataradov/edbg \
    && cd edbg \
    && git checkout -q ${EDBG_VERSION} \
    && make -j"$(nproc)" \
    && make all

ARG DOCKER_REGISTRY
FROM ${DOCKER_REGISTRY}/riotdocker-base

LABEL maintainer="francois-xavier.molina@inria.fr"

ARG FLASH_DEPS="make unzip wget"

ARG EDBG_DEPS=""

# Upgrading system packages to the latest available versions
RUN apt-get update && apt-get -y dist-upgrade
# Installing required packages for flashing toolchain
RUN apt-get -y --no-install-recommends install \
        ${EDBG_DEPS} \
        ${FLASH_DEPS} \
    # Cleaning up installation files
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy edbg binary from previous stage
COPY --from=builder /opt/edbg/edbg /usr/local/bin/edbg

# Set default EDBG in the environment
ENV EDBG=/usr/local/bin/edbg
