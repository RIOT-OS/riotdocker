#!/bin/sh

[ -f "/etc/conf.d/murdock" ] && . /etc/conf.d/murdock

MURDOCK_INSTANCE=${MURDOCK_INSTANCE:-murdock_slave}
MURDOCK_HOSTNAME=${MURDOCK_HOSTNAME:-$(hostname)}
MURDOCK_USER=${MURDOCK_USER:-murdock}
MURDOCK_HOME=$(eval echo ~${MURDOCK_USER})
MURDOCK_QUEUES=${MURDOCK_QUEUES:-default-first default}
MURDOCK_WORKERS=${MURDOCK_WORKERS:-4}
MURDOCK_TMPFS_SIZE=${MURDOCK_TMPFS_SIZE:-$((${MURDOCK_WORKERS}/2))g}
MURDOCK_CONTAINER=riot/murdock-worker:latest

mount_ccache_tmpfs() {
    local ccache_dir=${MURDOCK_HOME}/.ccache
    mount | grep -q ${ccache_dir} && return

    mkdir -p "$ccache_dir"

    mount -t tmpfs -o rw,nosuid,nodev,noexec,noatime,size=${MURDOCK_CCACHE_SIZE:-4g} tmpfs ${ccache_dir}

    {
        echo "max_size = 3.0G"
        echo "max_files = 1000000"
        echo "compression = true"
    } > ${ccache_dir}/ccache.conf

    chown -R murdock ${ccache_dir}
}

_start() {
    [ "$MURDOCK_CCACHE_TMPFS" = "1" ] && mount_ccache_tmpfs

    if [ "$MURDOCK_SYSTEMD" = "1" ]; then
        MURDOCK_DETACH=""
    else
        MURDOCK_DETACH="-d"
    fi

    exec docker run ${MURDOCK_DETACH} -u $(id -u ${MURDOCK_USER}) \
        --tmpfs /tmp:size=${MURDOCK_TMPFS_SIZE},exec,nosuid \
        -v ${MURDOCK_HOME}:/data/riotbuild \
        ${MURDOCK_CCACHEDIR:+-v ${MURDOCK_CCACHEDIR}:/data/riotbuild/.ccache} \
        ${MURDOCK_DOCKER_ARGS} \
        -e CCACHE="ccache" \
        -e CCACHE_MAXSIZE \
        -e DWQ_SSH \
        ${MURDOCK_CPUSET_CPUS:+--cpuset-cpus=${MURDOCK_CPUSET_CPUS}} \
        ${MURDOCK_CPUSET_MEMS:+--cpuset-mems=${MURDOCK_CPUSET_MEMS}} \
        --security-opt seccomp=unconfined \
        --name ${MURDOCK_INSTANCE} \
        ${MURDOCK_CONTAINER} \
        murdock_slave \
        --name $MURDOCK_HOSTNAME \
        --queues ${MURDOCK_HOSTNAME} ${MURDOCK_QUEUES} \
        ${MURDOCK_WORKERS:+--jobs ${MURDOCK_WORKERS}}
}

_stop() {
    docker kill ${MURDOCK_INSTANCE}
    docker rm ${MURDOCK_INSTANCE} >/dev/null 2>&1
}

case $1 in
    test)
        docker ps | grep -s -q "\\s${MURDOCK_INSTANCE}\$"
        ;;
    start)
        if [ "$MURDOCK_SYSTEMD" != "1" ]; then
            _stop
            docker pull ${MURDOCK_CONTAINER}
        fi
        _start
        ;;
    stop)
        _stop
        ;;
esac
