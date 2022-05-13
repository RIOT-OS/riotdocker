ARG DOCKER_REGISTRY="riot"
FROM ${DOCKER_REGISTRY}/riotdocker-base:latest

COPY debian/control /dpkg-build/debian/
# When playing with these, it is often practical to remove the comments on the
# `# true` / ... / `# RUN \` blocks (making the resulting images larger because
# of the intermediate files in the chain, but quick to rebuild on small
# changes) and moving the COPY lines down before the `dpkg-buildpackage` to not
# download and install all the dependencies again. The control file needs to
# stay up there as it influences what will be installed.
COPY debian/rules /dpkg-build/debian/
COPY debian/changelog /dpkg-build/debian/

# noninteractive for the tzinfo
RUN \
    echo 'Update the package index files to latest available versions' >&2 && \
    apt-get update && \
    echo 'Install Build / install dependencies' >&2 && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        debhelper \
        devscripts \
        dpkg-dev \
        equivs \
        && \
    mk-build-deps -i /dpkg-build/debian/control -t 'apt-get -y --no-install-recommends' && \
    echo 'Clean up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
#     true
#
# # Note that --profile minimal doesn't cut it
# RUN \
    echo 'Install c2rust rust' >&2 && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
#     true
#
# # Build using the provided Debian package sources
# #
# RUN \
    mkdir -p /dpkg-build/debian && \
    cd /dpkg-build && \
#     true
#
# # Build using Debian's mechanism; the actual build line is in ./debian/rules
# RUN \
    cd /dpkg-build && \
    PATH=~/.cargo/bin:$PATH dpkg-buildpackage -b && \
    cd / && \
#     true
#
# # Cleaning up as the relevant files were copied out, and the rest would just
# # make for a large image (which should only contain a minimal delta to the base
# # image in the end: the installed dependencies (libllvm), the installed
# # binaries and the debs that contain the stripped binaries and separate debug
# # symbols once more)
# RUN \
    rm -rf /dpkg-build && \
    rm -rf ~/.cargo && \
    rm -rf ~/.rustup && \
#     true
#
# # Besides copying the c2rust files to /usr/bin (which could also have been done
# # with --root /usr in the cargo line), this also ensures that the dependencies
# # stick around through the next step.
# RUN \
    apt-get -y install /c2rust_*.deb && \
#     true
#
# # Provide the package in an easy to match place independent of version and
# # architecture
# RUN \
    cp -l /c2rust_*.deb /c2rust.deb && \
#     true
#
# # TBD: Deduplicate list with above; feisty apt-get has no --mark-auto,
# # otherwise we could just --mark-auto above and autoremove --purge here.
# RUN \
    echo 'Removing packages only needed for building from container' >&2 && \
    apt-get purge -y --auto-remove \
        build-essential \
        ca-certificates \
        curl \
        debhelper \
        devscripts \
        dpkg-dev \
        equivs \
        c2rust-build-deps \
        && \
    echo 'Cleanup done'

# Check they're still executable
RUN c2rust --version
RUN c2rust-transpile --version
