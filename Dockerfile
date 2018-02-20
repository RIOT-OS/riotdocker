#
# RIOT Murdock Dockerfile
#
# the resulting image is being used in RIOT's CI (Murdock)

FROM riot/riotbuild

MAINTAINER Kaspar Schleiser <kaspar@schleiser.de>

ENV DEBIAN_FRONTEND noninteractive

RUN \
    echo 'Upgrading all system packages to the latest available versions' >&2 && \
    apt-get update && apt-get -y dist-upgrade \
    && echo 'Installing dwq dependencies' >&2 && \
    apt-get -y install \
        python3-pip autossh \
    && echo 'Cleaning up installation files' >&2 && \
        apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install dwq (disque work queue)
RUN pip3 install dwq

# install testrunner dependencies
RUN pip3 install click

# get git-cache directly from github
RUN wget https://github.com/kaspar030/git-cache/raw/master/git-cache \
        -O /usr/bin/git-cache \
        && chmod a+x /usr/bin/git-cache

# install murdock slave startup script
COPY murdock_slave.sh /usr/bin/murdock_slave

ENTRYPOINT ["/bin/bash", "/run.sh"]

# By default, run a shell when no command is specified on the docker command line
CMD ["/bin/bash"]
