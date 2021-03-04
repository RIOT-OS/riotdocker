ARG TARGETPLATFORM
ARG DOCKERHUB_REGISTRY="riot"
FROM ${DOCKERHUB_REGISTRY}/riotdocker-base

LABEL maintainer="francois-xavier.molina@inria.fr"

ARG FLASH_DEPS="make unzip"
ARG EDBG_INSTALL_DEPS="wget ca-certificates"

ARG JLINK_VERSION=694d
ARG JLINK_DEPS=""

# Upgrading system packages to the latest available versions
RUN apt-get update && apt-get -y dist-upgrade
# Installing required packages for flashing toolchain
RUN apt-get -y --no-install-recommends install \
        ${JLINK_DEPS} \
        ${EDBG_INSTALL_DEPS} \
        ${FLASH_DEPS} \
    # Cleaning up installation files
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Jlink
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ] ; \
        then export ARCH="x86_64"; \
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ] ; \
        then export ARCH="arm64"; \
    elif [ "${TARGETPLATFORM}" = "linux/arm/v7" ] ; \
        then export ARCH="arm"; \
    fi \
    && echo $ARCH \
    && wget --no-check-certificate --post-data 'accept_license_agreement=accepted&non_emb_ctr=confirmed&submit="Download software"'\
    https://www.segger.com/downloads/jlink/JLink_Linux_V${JLINK_VERSION}_${ARCH}.deb \
    && dpkg --install JLink_Linux_V${JLINK_VERSION}_${ARCH}.deb \
    && rm JLink_Linux_V${JLINK_VERSION}_${ARCH}.deb
