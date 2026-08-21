# riotbuild
Dockerfiles for creating build environment for building RIOT projects.

## Building your own images

The RIOT build system containers are staggered. The foundation is set by
`riotdocker-base`, which sets up the user inside of the container and
sets traps for `SIGINT` and `SIGTERM` signals.

You can build the image with the following command:

```sh
docker build --pull -t riotdocker-base ./riotdocker-base/
```

The second image, `static-test-tools`, builds upon `riotdocker-base` and
contains all of the tools that are required to run the RIOT static tests.
This image is also used by the `static-test` GitHub workflow in the main
`RIOT` repository.

You can build the image with the following command. Setting the
`DOCKER_REGISTRY` argument ensures that the local copy of the container is used
instead of the upstream version. You can omit this parameter if you haven't
made any changes to `riotdocker-base`.

***NOTE:*** If docker complains about not finding the image, you can try to
set the `DOCKER_REGISTRY` argument to `localhost` instead.

```sh
docker build --build-arg DOCKER_REGISTRY=docker.io/library -t static-test-tools ./static-test-tools/
```

The third image, `riotbuild`, builds upon the `static-test-tools` and contains
the full build environment required to build all platforms in `RIOT`.
This container is rather big (>10GB) and takes a good while to build.

You can run the following command to build it. Again, the `DOCKER_REGISTRY`
command is optional if you haven't made any changes to `static-test-tools`.

```sh
docker build --build-arg DOCKER_REGISTRY=docker.io/library -t riotbuild ./riotbuild/
```

The fourth image, `murdock-worker`, builds upon `riotbuild` and contains
everything that is used by the CI and can be built with the following command.
Again, the `DOCKER_REGISTRY` command is optional if you haven't made any
changes to `riotbuild`.

```sh
docker build --build-arg DOCKER_REGISTRY=docker.io/library -t murdock-worker ./murdock-worker/
```

## Testing your changes

Before you can test your changes, you have to find out the Image ID of your
freshly baked container. For example, if you want to search for `riotbuild`,
you can have docker list all containers that match that name.

```sh
riotdocker$ docker image list riotbuild
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
riotbuild    latest    f610ef8e4bbd   19 minutes ago   14.9GB
```

Depending on your changes and what you want to test, you can either start a
shell inside of the container with the following command:

```sh
docker run --rm --user $(id -u):$(id -g) -it f610ef8e4bbd bash
riotbuild@f610ef8e4bbd:~$
```

Or you can pass your image to the RIOT build system and build an application
or test of your liking:

```sh
BUILD_IN_DOCKER=1 DOCKER_IMAGE=f610ef8e4bbd BOARD=nrf52840dk make -C tests/sys/shell
```

## Notes for Release Managers

The version in `.github/workflows/build.yml` has to be advanced on every RIOT
release and be ahead of the RIOT release. For example, when RIOT 2026.07 was
released, the version for the docker container has to be advanced to 2026.10.

By advancing the version, the image version matching the RIOT release version
on the Docker Hub will not be changed anymore by changes to the container
repository and therefore will not cause issues with the Buildsystem Sanity
Check of RIOT.
