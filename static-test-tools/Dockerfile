ARG DOCKER_REGISTRY="riot"
FROM ${DOCKER_REGISTRY}/riotdocker-base:latest

LABEL maintainer="alexandre.abadie@inria.fr"

ENV DEBIAN_FRONTEND noninteractive

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN \
    --mount=type=bind,source=build.sh,target=/root/build.sh \
    --mount=type=bind,source=requirements.txt,target=/root/requirements.txt \
    cd /root && ./build.sh
