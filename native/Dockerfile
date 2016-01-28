#
# RIOT Dockerfile
#
# the resulting image will contain everything needed to build RIOT for the
# native platform _only_.
#
# Setup: (only needed once per Dockerfile change)
# 1. install docker, add yourself to docker group, enable docker, relogin
# 2. # docker build -t riotbuild .
#
# Usage:
# 3. cd to riot root
# 4. # docker run -i -t -u $UID -v $(pwd):/data/riotbuild riotbuild ./dist/tools/compile_test/compile_test.py

FROM debian:jessie

MAINTAINER Joakim Nohlgård <joakim.nohlgard@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

# Add backports repository for gcc-arm-none-eabi 4.9 on jessie
# Fetch package repository and upgrade all system packages to latest available version
RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' > \
    /etc/apt/sources.list.d/backports.list && \
    apt-get update && apt-get -y dist-upgrade

# native platform development and build system functionality (about 400 MB installed)
RUN apt-get -y install \
    build-essential \
    curl \
    gcc-multilib \
    g++-multilib \
    git \
    libpcre3 \
    pcregrep \
    python \
    python3 \
    p7zip \
    subversion \
    unzip \
    wget

# # LLVM/Clang build environment (about 125 MB installed)
# RUN apt-get -y install \
#     llvm \
#     clang

RUN mkdir -p /data/riotbuild
WORKDIR /data/riotbuild

