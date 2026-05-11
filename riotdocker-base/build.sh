#!/bin/bash

# Automatically exit on error
set -e

COUNTER_STEP=0
COUNTER_SUBSTEP=0
BLUE="\e[34m"
BOLD="\e[1m"
NORMAL="\e[0m"

step() {
    COUNTER_SUBSTEP=0
    COUNTER_STEP=$(("$COUNTER_STEP" + 1))
    printf "${BLUE}${BOLD}==>${NORMAL}${BOLD} Step %d:${NORMAL} %s\n" "$COUNTER_STEP" "$1"
}

substep() {
    COUNTER_SUBSTEP=$(("$COUNTER_SUBSTEP" + 1))
    printf "${BLUE}${BOLD}    -->${NORMAL}${BOLD} Step %d.%d:${NORMAL} %s\n" \
        "$COUNTER_STEP" "$COUNTER_SUBSTEP" "$1"
}

step_install_dev_tools() {
    step "Installing development tools"

    substep "Updating package index"
    apt-get update

    substep "Installing GCC"
    apt-get -y --no-install-recommends install gcc

    substep "Installing git"
    apt-get -y --no-install-recommends install git

    substep "Installing Python"
    apt-get -y --no-install-recommends install \
        python3 \
        python3-dev \
        python3-pip

    substep "Clean up installation files"
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}

step_provide_create_user_cmd() {
    step "Providing create_user binary"

    substep "Compiling create_user from source"
    gcc -DHOMEDIR=\"/data/riotbuild\" -DUSERNAME=\"riotbuild\" create_user.c -o /usr/local/bin/create_user

    substep "Updating file attributes of create_user"
    chown root:root /usr/local/bin/create_user
    chmod u=rws,g=x,o=- /usr/local/bin/create_user
}

step_setup_dirs() {
    step "Setting up folders and files"

    substep "Creating /data/riotbuild"
    mkdir -m 777 -p /data/riotbuild

    substep "Creating /run.sh"
    cp run.sh /run.sh
}

step_setup_git() {
    step "Setting up git"

    substep "Configuring user and email"
    git config --system user.name "riot"
    git config --system user.email "riot@example.com"

    substep "Setting up safe directories"
    git config --system --add safe.directory /data/riotbuild
}

step_install_dev_tools
step_provide_create_user_cmd
step_setup_dirs
step_setup_git
exit 0
