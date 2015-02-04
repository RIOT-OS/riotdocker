#
# RIOT Dockerfile
#
# the resulting image will contain everything needed to build RIOT for avr-based
# platforms.
#
# Setup: (only needed once per Dockerfile change)
# 1. install docker, add yourself to docker group, enable docker, relogin
# 2. # docker build -t riotbuild .
#
# Usage:
# 3. cd to riot root
# 4. # docker run -i -t -u $UID -v $(pwd):/data/riotbuild riotbuild ./dist/tools/compile_test/compile_test.py

FROM gebart/riotbuild:native

MAINTAINER Joakim Gebart <joakim.gebart@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

# AVR development (about 110 MB installed)
RUN apt-get -y install \
    gcc-avr \
    binutils-avr \
    avr-libc

RUN mkdir -p /data/riotbuild
WORKDIR /data/riotbuild

