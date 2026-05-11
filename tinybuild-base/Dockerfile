ARG DOCKER_REGISTRY="docker.io/riot"
FROM alpine:latest
LABEL maintainer="Marian Buschsieweke <marian.buschsieweke@posteo.net>"

RUN \
    --mount=type=cache,id=apk-cache,sharing=locked,target=/var/cache/apk \
    --mount=type=bind,target=/tinybuild-apks,source=/output,from=tinybuild-apks \
    echo "@riotapks /tinybuild-apks/riotapks" >> /etc/apk/repositories && \
    cp /tinybuild-apks/*.rsa.pub /etc/apk/keys/ && \
    apk update && \
    apk add \
        python3 \
        make \
        unzip \
        git
