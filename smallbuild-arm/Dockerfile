ARG DOCKER_REGISTRY="docker.io/riot"
FROM ${DOCKER_REGISTRY}/smallbuild-base:latest

LABEL maintainer="Marian Buschsieweke <marian.buschsieweke@posteo.net>"

RUN \
    --mount=type=cache,id=apk-cache,sharing=locked,target=/var/cache/apk \
    --mount=type=bind,target=/tinybuild-apks,source=/output,from=tinybuild-apks \
    apk add \
        newlib-arm-none-eabi \
        picolibc-arm-none-eabi \
        g++-arm-none-eabi  && \
    CARGO_HOME=/opt/rustup/.cargo sh -c "\
        rustup target add thumbv7em-none-eabihf && \
        rustup target add thumbv7em-none-eabi && \
        rustup target add thumbv7m-none-eabi && \
        rustup target add thumbv6m-none-eabi && \
        rustup target add thumbv8m.main-none-eabihf && \
        rustup target add thumbv8m.main-none-eabi && \
        rustup target add thumbv8m.base-none-eabi"
