ARG DOCKER_REGISTRY="riot"
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

ARG UNCRUSTIFY_URL=https://github.com/kaspar030/uncrustify-builder/releases/download/0.72.0/uncrustify-0.72.0.gz
ARG UNCRUSTIFY_BIN=/usr/local/bin/uncrustify
RUN echo 'Installing uncrustify binary' >&2 && \
    wget $UNCRUSTIFY_URL -O ${UNCRUSTIFY_BIN}.gz && \
    gunzip ${UNCRUSTIFY_BIN}.gz && \
    chmod 0755 ${UNCRUSTIFY_BIN}
