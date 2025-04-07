# This docker is not intended to be run, it is rather an intermediate step
# to create custom packages for consumption by other docker containers
FROM alpine:latest
LABEL maintainer="Marian Buschsieweke <marian.buschsieweke@posteo.net>"

# install all package needed for building apks
RUN \
    --mount=type=cache,id=apk-cache,sharing=locked,target=/var/cache/apk \
    apk add \
        alpine-sdk \
        doas \
        findutils \
        lua-aports

# setup a user and create keys needed to sign apks
RUN \
    adduser -D builder && \
    adduser builder abuild && \
    echo "permit nopass builder as root" > /etc/doas.conf && \
    su builder -c 'abuild-keygen -ian' && \
    mkdir /output && \
    chmod 777 /output -R && \
    su builder -c 'cp ~/.abuild/*.rsa.pub /output/'

# create an output directory and build all packages from the aports folder
RUN \
    --mount=type=cache,id=apk-cache,sharing=locked,target=/var/cache/apk \
    --mount=type=bind,target=/var/aports,source=aports \
    su builder -c 'mkdir -p ~/aports && cp /var/aports ~/aports/riotapks -r' && \
    su builder -c 'buildrepo -d /output riotapks'

# built custom binaries that are not packaged
RUN \
    --mount=type=bind,target=/var/src,source=src \
    gcc -Os -Wall -Werror -Wpedantic -o /output/rustc /var/src/fixed-rustc.c
