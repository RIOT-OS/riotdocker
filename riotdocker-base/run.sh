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

# Create passwd entry with the UID and GID of the user running the
# `riotdocker-base` container and any containers derived from it.
# It also sets the HOME variable.
# Only execute, if the current UID does not exist.
if ! id "$(id -u)" >/dev/null 2>/dev/null; then
    if [ "$(id -u)" -ne 0 ] && [ "$(id -g)" -eq 0 ]; then
        # Fallback to UID:UID if the container is run without setting a GID
	echo -e "\e[33mWarning: The Docker User ID is $(id -u), but the" \
		"Group ID is 0 (root), update your RIOT repository or check" \
		"the Docker call!\e[0m"
        create_user "$(id -u)" "$(id -u)"
    else
        create_user "$(id -u)" "$(id -g)"
    fi
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
