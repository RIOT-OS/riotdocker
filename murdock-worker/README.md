# RIOT CI Container

## Setting up a murdock slave

## Overview

This guide has instructions on how to set up a slave for RIOT's Murdock 2
distributed build system.

The slave will run within a container and connect to Murdock's disque server
via ssh.

It needs a user, mainly for holding the ssh configuration and some cache directories.

## Requirements

The current default configuration will need about 8gb RAM.

The mentioned "murdock_slave_homedir.tgz" can be obtained from
kaspar@schleiser.de.

## Setup

1. create user

    $ sudo useradd -r -d /srv/murdock murdock

2. add the `id_rsa_murdock-slave` file from Kaspar to /home/murdock/.ssh

3. tbd

