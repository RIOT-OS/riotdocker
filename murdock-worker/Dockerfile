# RIOT Murdock Dockerfile
#
# the resulting image is being used in RIOT's CI (Murdock)

ARG DOCKER_REGISTRY="docker.io/riot"
FROM ${DOCKER_REGISTRY}/riotbuild:latest

LABEL maintainer="Kaspar Schleiser <kaspar@riot-os.org>"

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    echo 'Upgrading all system packages to the latest available versions' >&2 && \
    apt-get update && apt-get -y dist-upgrade \
    && echo 'Installing dependencies' >&2 && \
    apt-get -y install \
        python3-pip autossh python3-setuptools redis-tools \
    && echo 'Cleaning up installation files' >&2 && \
        apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install dwq (disque work queue)
RUN pip3 install dwq==0.1.0

# install hiredis -- not required directly, but redis (from dwq) will spew
# warnings otherwise that break things somewhere further down the line.
RUN pip3 install hiredis

# install testrunner dependencies
RUN pip3 install click

# install newer ccache package
ARG CCACHE_TGZ=ccache-4.7.4-linux-x86_64.tar.xz
COPY files/${CCACHE_TGZ}  /
RUN tar -xvf /${CCACHE_TGZ} --strip-components=1 -C/usr/local/bin && rm /${CCACHE_TGZ}

# install murdock slave startup script
COPY murdock_slave.sh /usr/bin/murdock_slave

# create cache folder
RUN mkdir -m777 /cache

# remove old git-cache-rs files from before the directory structure changed
RUN rm -rf /cache/.gitcache/*.git /cache/.gitcache/*.lock

# set cache folder for Download Cache
ENV DLCACHE_DIR=/cache/.dlcache

ENTRYPOINT ["/bin/bash", "/run.sh"]

# By default, run a shell when no command is specified on the docker command line
CMD ["/bin/bash"]
