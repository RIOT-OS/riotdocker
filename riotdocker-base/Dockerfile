FROM ubuntu:jammy

LABEL maintainer="Kaspar Schleiser <kaspar@riot-os.org>"

RUN \
    --mount=type=bind,source=build.sh,target=/root/build.sh \
    --mount=type=bind,source=run.sh,target=/root/run.sh \
    --mount=type=bind,source=create_user.c,target=/root/create_user.c \
    cd /root && ./build.sh

ENTRYPOINT ["/bin/bash", "/run.sh"]

# By default, run a shell when no command is specified on the docker command line
CMD ["/bin/bash"]

WORKDIR /data/riotbuild
