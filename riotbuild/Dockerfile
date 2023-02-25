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
ARG DOCKER_REGISTRY="riot"
FROM ${DOCKER_REGISTRY}/static-test-tools:latest

LABEL maintainer="Kaspar Schleiser <kaspar@riot-os.org>"

ARG RIOTBUILD_VERSION=unknown
ARG RIOTBUILD_COMMIT=unknown
ARG RIOTBUILD_BRANCH=unknown

ENV DEBIAN_FRONTEND="noninteractive" \
    LC_ALL="C.UTF-8" \
    LANG="C.UTF-8" \
    ESP8266_RTOS_SDK_DIR="/opt/esp/ESP8266_RTOS_SDK" \
    RUSTUP_HOME="/opt/rustup/.rustup" \
    PATH="${PATH}:/opt/arm-none-eabi/bin:/opt/riscv-none-elf/bin:/opt/esp/xtensa-esp8266-elf/bin:/opt/esp/xtensa-esp32-elf/bin:/opt/esp/qemu/bin:/opt/esp/riscv32-esp-elf/bin:/opt/esp/xtensa-esp32s2-elf/bin:/opt/esp/xtensa-esp32s3-elf/bin:/opt/msp430-elf/bin:/opt/rustup/.cargo/bin" \
    RIOTBUILD_VERSION="$RIOTBUILD_VERSION" \
    RIOTBUILD_COMMIT="$RIOTBUILD_COMMIT" \
    RIOTBUILD_BRANCH="$RIOTBUILD_BRANCH"

RUN \
    --mount=type=bind,source=build.sh,target=/root/build.sh \
    --mount=type=bind,source=requirements.txt,target=/root/requirements.txt \
    --mount=type=bind,source=files/libsocketcan-dev_0.0.11-1_i386.deb,target=/root/libsocketcan-dev_0.0.11-1_i386.deb \
    --mount=type=bind,source=files/libsocketcan2_0.0.11-1_i386.deb,target=/root/libsocketcan2_0.0.11-1_i386.deb \
    cd /root && ./build.sh

