#FROM immunant/c2rust:ubuntu-bionic-latest as c2rust
# Could use ../riotdocker-base after <https://github.com/RIOT-OS/riotdocker/pull/104>.
FROM ubuntu:focal

# noninteractive for the tzinfo
#
# The first block is for actually building c2rust, the second for building a
# Debian package.
RUN \
    echo 'Update the package index files to latest available versions' >&2 && \
    apt-get update && \
    echo 'Install Build / install dependencies' >&2 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        git \
        pkg-config \
        libclang-dev \
        libssl-dev \
        llvm-dev \
        \
        debhelper \
        devscripts \
        dpkg-dev \
        && \
    echo 'Clean up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Note that --profile minimal doesn't cut it
RUN \
    echo 'Install c2rust rust nightly' >&2 && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly-2019-12-05

# --locked --git --branch ignores --locked; new (2021-03-something) cargo
# versions behave properly, but C2Rust is on a 2019-12-05 toolchain.
RUN git clone --recursive https://github.com/chrysn-pull-requests/c2rust -b for-riot && \
    ~/.cargo/bin/cargo install --locked --path c2rust/c2rust

COPY debian/control /dpkg-build/debian/
COPY debian/rules /dpkg-build/debian/

# Rather than going through manual motions like suggested in
# https://bugs.debian.org/993498 (using dpkg-shlibdeps to find which of the
# packages pulled through build-deps are actually needed), builing a package is
# really easy as long as no standards apply.
#
# (The `cp` should be c2rust*, but <https://github.com/immunant/c2rust/issues/349>).
RUN \
    mkdir -p /dpkg-build/debian && \
    cd /dpkg-build && \
    cp -a ~/.cargo/bin/c2rust ~/.cargo/bin/c2rust-transpile . && \
    ls -1 c2rust* | sed 's@$@ usr/bin@' > debian/install && \
    EDITOR=true dch --create --package c2rust --newversion 0.0 && \
    echo 10 > debian/compat && \
    dpkg-buildpackage -b && \
    cd / && \
    rm -rf /dpkg-build

# Cleaning up as the relevant files were copied out, and the rest would just
# make for a large image (which should only contain a minimal delta to the base
# image in the end)
RUN \
    rm -rf c2rust && \
    rm -rf ~/.cargo && \
    rm -rf ~/.rustup

# Besides copying the c2rust files to /usr/bin (which could also have been done
# with --root /usr in the cargo line), this also ensures that the dependencies
# stick around through the next step.
RUN \
    apt-get -y install /c2rust_0.0_*.deb

# TBD: Deduplicate list with above; feisty apt-get has no --mark-auto,
# otherwise we could just --mark-auto above and autoremove --purge here.
RUN \
    echo 'Removing packages only needed for building from container' >&2 && \
    apt-get purge -y --auto-remove \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        git \
        pkg-config \
        libclang-dev \
        libssl-dev \
        llvm-dev \
        \
        debhelper \
        devscripts \
        dpkg-dev \
        && \
    echo 'Cleanup done'

# Check they're still executable
RUN c2rust --version
RUN c2rust-transpile --version
