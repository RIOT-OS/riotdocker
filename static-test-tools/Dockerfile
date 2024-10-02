ARG DOCKER_REGISTRY="docker.io/riot"
FROM ${DOCKER_REGISTRY}/riotdocker-base:latest

LABEL maintainer="alexandre.abadie@inria.fr"

ENV DEBIAN_FRONTEND noninteractive

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN \
    echo 'Update the package index files to latest available versions' >&2 && \
    apt-get update && \
    echo 'Installing static test tools' >&2 && \
    apt-get -y --no-install-recommends install \
        coccinelle \
        cppcheck \
        curl \
        doxygen \
        graphviz \
        less \
        make \
        pcregrep \
        shellcheck \
        vera++ \
        wget \
        && \
    echo 'Cleaning up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install required Python packages
COPY requirements.txt /tmp/requirements.txt
RUN echo 'Installing python3 packages' >&2 && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt

# Install uncrustify
COPY --from=ghcr.io/kaspar030/uncrustify-builder:latest /usr/bin/uncrustify /usr/bin/uncrustify

# Rust base installation

# While sourcing ~/.cargo/env later would have the right short-term effect,
# we'd still need to set the right path even later when HOME is
# /data/riotbuild -- so setting it right away.
ENV PATH ${PATH}:/opt/rustup/.cargo/bin

# Install Rust via rustup; this is needed for Rust-on-RIOT builds and contains
# all CARGO_TARGETs currently recognized for RIOT targets.
#
# *_HOMEs moved to /opt to make them world readable. RUSTUP_HOME is set
# persistently in case someone in their image wants to do a quick `sudo rustup
# toolchain add` or similar; CARGO_HOME is not because the user will need to
# write there, and all rustup does here is to place some binaries that later
# fan out to RUSTUP_HOME anyway.
#
# Components: fmt is needed for the static test tools as those do `cargo fmt`
# checks. More are added for riotbuild.
ENV RUSTUP_HOME /opt/rustup/.rustup
RUN \
    CARGO_HOME=/opt/rustup/.cargo sh -c "\
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal && \
    rustup component add rustfmt"
