#!/bin/bash

# Automatically exit on error
set -e

COUNTER_STEP=0
COUNTER_SUBSTEP=0
BLUE="\e[34m"
BOLD="\e[1m"
NORMAL="\e[0m"

UNCRUSTIFY_VERSION="0.76.0"
UNCRUSTIFY_SHA256="32e2f95485a933fc5667880f1a09a964ae83132c235bb606abbb0a659453acb3"
UNCRUSTIFY_URL="https://github.com/uncrustify/uncrustify/archive/refs/tags/uncrustify-$UNCRUSTIFY_VERSION.tar.gz"

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

step_prepare_apt() {
    step "Updating apt package index"
    apt-get update
}

step_install_apt_packages() {
    step "Installing packages via apt package manager"

    substep "Installing base shell utilities"
    apt-get -y --no-install-recommends install wget less pcregrep

    substep "Installing tools to generate documentation"
    apt-get -y --no-install-recommends install make doxygen graphviz

    substep "Installing linting tools"
    apt-get -y --no-install-recommends install coccinelle cppcheck shellcheck vera++
}

step_install_pip_packages() {
    step "Installing python packages via pip"
    pip3 install --no-cache-dir -r requirements.txt
}

step_build_uncrustify() {
    step "Building uncrustify"

    local olddir
    olddir="$(pwd)"

    substep "Installing build requirements"
    apt-get -y --no-install-recommends install cmake g++

    substep "Preparing build dir and downloading source"
    cd /tmp
    wget "$UNCRUSTIFY_URL"

    substep "Verifying and unpacking source"
    echo "$UNCRUSTIFY_SHA256 $(basename "$UNCRUSTIFY_URL")" | sha256sum -c -
    tar xf "$(basename "$UNCRUSTIFY_URL")"
    mkdir "uncrustify-uncrustify-$UNCRUSTIFY_VERSION"/build
    cd "uncrustify-uncrustify-$UNCRUSTIFY_VERSION"/build

    substep "Running cmake"
    cmake .. -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DCMAKE_EXE_LINKER_FLAGS="-static"

    substep "Running make"
    make

    substep "Strip and install binary"
    strip uncrustify
    install -Dm755 uncrustify /usr/bin/uncrustify

    substep "Cleaning up build files and removing build dependencies"
    cd "$olddir"
    apt-get -y purge cmake g++
    rm -rf /tmp/uncrustify-*
}

step_clean_apt() {
    step "Cleaning up apt package index and temporary files"
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}

step_prepare_apt
step_install_apt_packages
step_install_pip_packages
step_build_uncrustify
step_clean_apt
exit 0
