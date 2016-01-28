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
    "$@" &
    masterpid="$!"
    trap "terminateall $masterpid" EXIT SIGINT SIGTERM

    # Wait for the top level child process to terminate
    while kill -0 $masterpid > /dev/null 2>&1; do
        wait
    done
}

runcommand "$@"

# no need to run the EXIT handler on a clean exit
trap - EXIT
