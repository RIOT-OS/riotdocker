ARG DOCKER_REGISTRY="docker.io/riot"
FROM ${DOCKER_REGISTRY}/tinybuild-base:latest
LABEL maintainer="Marian Buschsieweke <marian.buschsieweke@posteo.net>"

ENV \
    RUSTUP_HOME=/opt/rustup/.rustup \
    PATH=${PATH}:/opt/rustup/.cargo/bin

RUN \
    --mount=type=cache,id=apk-cache,sharing=locked,target=/var/cache/apk \
    --mount=type=bind,target=/tinybuild-apks,source=/output,from=tinybuild-apks \
    apk add \
        rustup \
        musl-dev \
        clang-libclang \
        c2rust@riotapks && \
    CARGO_HOME=/opt/rustup/.cargo rustup-init -y && \
    cp /tinybuild-apks/rustc /opt/rustup/.cargo/bin
