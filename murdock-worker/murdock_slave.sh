#!/bin/sh

autossh -M 0 -f -C -N -L7711:localhost:7711 -L6379:localhost:6379 \
    -o ServerAliveInterval=60 -o ServerAliveCountMax=2 \
    ${DWQ_SSH:-murdock}

git-cache init || {
    echo "Error initializing git-cache. Permission problem?"
    exit 1
}

exec dwqw $*
