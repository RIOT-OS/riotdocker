#FROM immunant/c2rust:ubuntu-bionic-latest as c2rust
# Could use ../riotdocker-base after <https://github.com/RIOT-OS/riotdocker/pull/104>.
FROM ubuntu:focal

# noninteractive for the tzinfo that gets pulled in through cmake
RUN \
    echo 'Update the package index files to latest available versions' >&2 && \
    apt-get update && \
    echo 'Install Build / install dependencies' >&2 && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        git \
        pkg-config \
        libclang-dev \
        libssl-dev \
        llvm-dev \
        && \
    echo 'Clean up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Note that --profile minimal doesn't cut it
RUN \
    echo 'Install c2rust rust nightly' >&2 && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly-2019-12-05

# --locked --git --branch ignores --locked; new (2021-03-something) cargo
# versions behave properly, but C2Rust is on a 2019-12-05 toolchain.
#
# Cleaning up cargo home again as set by C2Rust image (that's what contributes
# most to the delta between the immunant container and this one).
RUN git clone --recursive https://github.com/chrysn-pull-requests/c2rust -b for-riot && \
    ~/.cargo/bin/cargo install --locked --root /usr --path c2rust/c2rust && \
    rm -rf c2rust && \
    rm -rf ~/.cargo \
    rm -rf ~/.rustup
