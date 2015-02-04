#
# RIOT Dockerfile
#
# the resulting image will contain everything needed to build RIOT for bare
# metal x86 platforms.
#
# Setup: (only needed once per Dockerfile change)
# 1. install docker, add yourself to docker group, enable docker, relogin
# 2. # docker build -t riotbuild .
#
# Usage:
# 3. cd to riot root
# 4. # docker run -i -t -u $UID -v $(pwd):/data/riotbuild riotbuild ./dist/tools/compile_test/compile_test.py

FROM gebart/riotbuild:native-only

MAINTAINER Joakim Gebart <joakim.gebart@eistec.se>

ENV DEBIAN_FRONTEND noninteractive

# x86 bare metal emulation (about 125 MB installed) (this pulls in all of X11)
RUN apt-get -y install \
    qemu-system-x86


RUN mkdir -p /data/riotbuild
WORKDIR /data/riotbuild

