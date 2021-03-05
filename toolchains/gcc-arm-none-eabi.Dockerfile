ARG DOCKERHUB_REGISTRY="riot"
FROM ${DOCKERHUB_REGISTRY}/gcc-arm-none-eabi.lite as gcc-arm-none-eabi
FROM ${DOCKERHUB_REGISTRY}/riotbuild-essentials

LABEL maintainer="francois-xavier.molina@inria.fr"

# Install ARM GNU embedded toolchain
ARG ARM_FOLDER=gcc-arm-none-eabi
RUN mkdir -p /opt/${ARM_FOLDER}
COPY --from=gcc-arm-none-eabi /opt/${ARM_FOLDER} /opt/${ARM_FOLDER}
# Add to PATH
ENV PATH ${PATH}:/opt/${ARM_FOLDER}/bin
