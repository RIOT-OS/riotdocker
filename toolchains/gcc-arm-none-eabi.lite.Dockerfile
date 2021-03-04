ARG DOCKER_REGISTRY="riot"
FROM ${DOCKER_REGISTRY}/riotdocker-base
LABEL maintainer="francois-xavier.molina@inria.fr"

# Dependencies to install gcc-arm-none-eabi
ARG ARM_INSTALL_DEPS="curl bzip2"
# Dependencies to compile gcc-arm-none-eabi
ARG ARM_BUILD_DEPS="make unzip"

# Upgrading system packages to the latest available versions
RUN apt-get update && apt-get -y dist-upgrade
# Installing required packages for flashing toolchain
RUN apt-get -y --no-install-recommends install \
        ${ARM_INSTALL_DEPS} \
        ${ARM_BUILD_DEPS} \
    # Cleaning up installation files
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH ${PATH}:/opt/gcc-arm-none-eabi/bin
