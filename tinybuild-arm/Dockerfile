ARG DOCKER_REGISTRY="docker.io/riot"
FROM ${DOCKER_REGISTRY}/tinybuild-base:latest

LABEL maintainer="Marian Buschsieweke <marian.buschsieweke@posteo.net>"

RUN \
    --mount=type=cache,id=apk-cache,sharing=locked,target=/var/cache/apk \
    --mount=type=bind,target=/tinybuild-apks,source=/output,from=tinybuild-apks \
    apk add \
        newlib-arm-none-eabi \
        picolibc-arm-none-eabi
