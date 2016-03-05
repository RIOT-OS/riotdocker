#
# RIOT Dockerfile
#
# the resulting image will contain everything needed to build RIOT for ARM bare
# metal platforms.
#
# Setup: (only needed once per Dockerfile change)
# 1. install docker, add yourself to docker group, enable docker, relogin
# 2. # docker build -t riotbuild .
#
# Usage:
# 3. cd to riot root
# 4. # docker run -i -t -u $UID -v $(pwd):/data/riotbuild riotbuild ./dist/tools/compile_test/compile_test.py

FROM riot/riotbuild:native-only

MAINTAINER Joakim Nohlgård <joakim.nohlgard@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

# For Ubuntu 14.04 only:
#RUN echo "deb http://ppa.launchpad.net/terry.guo/gcc-arm-embedded/ubuntu trusty main" > /etc/apt/sources.list.d/gcc-arm-embedded.list
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key FE324A81C208C89497EFC6246D1D8367A3421AFB
# You may need to specify the exact version of gcc-arm-none-eabi to install
# below, or else the old Debian version might get pulled in.
# Also, remove libnewlib-arm-none-eabi and libstdc++-arm-none-eabi-newlib from
# the install command below if using the above PPA as the gcc package has
# everything included.

# Fetch package repository
#RUN apt-get update

# Cortex-M development (about 550 MB installed)
RUN apt-get -t jessie-backports -y install \
    binutils-arm-none-eabi \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libstdc++-arm-none-eabi-newlib \
    libnewlib-dev

# LLVM/Clang build environment (about 125 MB installed)
RUN apt-get -y install \
    llvm \
    clang

RUN mkdir -p /data/riotbuild
WORKDIR /data/riotbuild

