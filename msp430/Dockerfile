#
# RIOT Dockerfile
#
# the resulting image will contain everything needed to build RIOT for msp430
# platforms.
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

# MSP430 development (about 120 MB installed)
RUN apt-get -y install \
    gcc-msp430

# # LLVM/Clang build environment (about 125 MB installed)
# RUN apt-get -y install \
#     llvm

RUN mkdir -p /data/riotbuild
WORKDIR /data/riotbuild

