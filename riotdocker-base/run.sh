#!/bin/bash
# A wrapper to trap the SIGINT and SIGTERM signals (Ctrl+C, kill) and forwards
# it to the child process as a SIGTERM
# Idea: https://github.com/docker-library/mysql/issues/47#issuecomment-147397851
# Further reading: https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/

terminateall() {
    for p in "$@"
    do
        echo "Stopping PID $p"
        kill -SIGTERM $p >/dev/null 2>/dev/null
    done
}

runcommand() {
    "$@" <&0 &
    masterpid="$!"
    trap "terminateall $masterpid" EXIT SIGINT SIGTERM
    retval="0"

    # Wait for the top level child process to terminate
    while kill -0 $masterpid > /dev/null 2>&1; do
        wait $masterpid
        retval="$?"
    done
    return "$retval"
}

# create passwd entry for current uid, fix HOME variable
# only execute, if the current uid does not exist.
if ! id $(id -u) >/dev/null 2>/dev/null; then
    create_user $(id -u)
fi
export HOME=/data/riotbuild

if [ $# = 0 ]; then
    echo "$0: No command specified" >&2
    # docker run also exits with error code 125 when no command is specified and
    # no custom entry point is used
    exit 125
else
    runcommand "$@"
fi
status="$?"

# no need to run the EXIT handler on a clean exit
trap - EXIT

exit "$status"
