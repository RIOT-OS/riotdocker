ARG DOCKER_REGISTRY="riot"
FROM ${DOCKER_REGISTRY}/static-test-tools

LABEL maintainer="francois-xavier.molina@inria.fr"

RUN \
    echo 'Update the package index files to latest available versions' >&2 && \
    apt-get update && \
    echo 'Installing riot-build-essentials' >&2 && \
    apt-get -y --no-install-recommends install \
        # required by RIOT build system
        unzip \
        curl \
        # for building many packades
        g++ \
        # required for hexdump
        bsdmainutils \
         # required for xxd
        vim-common \
        cmake \
        patch \
        # To install python packages (next two)
        python3-setuptools \
        python3-wheel \
        # For nanopb
        protobuf-compiler \
        # For picolibc
        ninja-build \
        && \
    echo 'Cleaning up installation files' >&2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install required Python packages
COPY requirements.txt /tmp/requirements.txt
# numpy must be already installed before installing other requirements
RUN pip3 install --no-cache-dir numpy==1.17.4
RUN echo 'Installing python3 packages' >&2 && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt
