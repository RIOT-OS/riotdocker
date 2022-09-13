#
# RIOT Murdock Dockerfile
#
# the resulting image is being used in RIOT's CI (Murdock)

ARG DOCKER_REGISTRY="riot"
FROM ${DOCKER_REGISTRY}/riotbuild:latest

LABEL maintainer="Kaspar Schleiser <kaspar@riot-os.org>"

ENV DEBIAN_FRONTEND noninteractive

RUN \
    echo 'Upgrading all system packages to the latest available versions' >&2 && \
    apt-get update && apt-get -y dist-upgrade \
    && echo 'Installing dependencies' >&2 && \
    apt-get -y install \
        python3-pip autossh python3-setuptools redis-tools \
    && echo 'Cleaning up installation files' >&2 && \
        apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install dwq (disque work queue)
RUN pip3 install dwq==0.0.56

# install hiredis -- not required directly, but redis (from dwq) will spew
# warnings otherwise that break things somewhere further down the line.
RUN pip3 install hiredis

# install testrunner dependencies
RUN pip3 install click

# get git-cache directly from github
RUN wget https://raw.githubusercontent.com/kaspar030/git-cache/f76c3a5f0e15f08c28e53fb037755f29f0b76d88/git-cache \
        -O /usr/bin/git-cache \
        && chmod a+x /usr/bin/git-cache

# install murdock slave startup script
COPY murdock_slave.sh /usr/bin/murdock_slave

ENTRYPOINT ["/bin/bash", "/run.sh"]

# By default, run a shell when no command is specified on the docker command line
CMD ["/bin/bash"]
