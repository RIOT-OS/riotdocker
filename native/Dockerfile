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

# Ubuntu 14.04
#FROM ubuntu:trusty
# Ubuntu 14.10
#FROM ubuntu:utopic
# Ubuntu 15.04
#FROM ubuntu:vivid
# same as jessie?
#FROM debian:testing
# same as testing?
FROM debian:jessie
# Debian unstable
#FROM debian:sid
# probably not a good idea to use this for your build needs.
#FROM debian:experimental

MAINTAINER Joakim Gebart <joakim.gebart@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

# Fetch package repository and upgrade all system packages to latest available version
RUN apt-get update && apt-get -y dist-upgrade

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
#     llvm

RUN mkdir -p /data/riotbuild
WORKDIR /data/riotbuild

