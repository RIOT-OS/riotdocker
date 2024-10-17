#
# Dockerfile for RIOT build environments with extra Rust nightly
#
# The resulting image will be based on riotdocker, but also install the current
# RIOT nightly versions to enable easy building of applications that need
# nightly.

ARG DOCKER_REGISTRY="docker.io/riot"
FROM ${DOCKER_REGISTRY}/riotbuild:latest

# For the value of CARGO_HOME, see the comments in riotbuild's Dockerfile.
RUN \
    set -ex; \
    export CARGO_HOME=/opt/rustup/.cargo; \
    rustup toolchain add nightly; \
    for target in $(rustup target list --installed); \
    do \
        rustup target add $target --toolchain nightly; \
    done; \
    rustup default nightly
