ARG DOCKER_REGISTRY="docker.io/riot"
FROM ${DOCKER_REGISTRY}/smallbuild-base:latest

LABEL maintainer="Marian Buschsieweke <marian.buschsieweke@posteo.net>"

RUN \
    --mount=type=cache,id=apk-cache,sharing=locked,target=/var/cache/apk \
    --mount=type=bind,target=/tinybuild-apks,source=/output,from=tinybuild-apks \
    apk add \
        newlib-riscv-none-elf \
        picolibc-riscv-none-elf \
        g++-riscv-none-elf && \
    CARGO_HOME=/opt/rustup/.cargo rustup target add riscv32imac-unknown-none-elf
