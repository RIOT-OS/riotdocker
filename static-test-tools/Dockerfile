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
