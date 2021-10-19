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

2. Extract murdock_slave_homedir.tgz into /srv
   (the archive contains ssh configuration)

   sudo tar -C /srv -xvf murdock_slave_homedir.tgz

3. make sure murdock user can ssh "murdock" without password

    $ sudo su -s /bin/sh - murdock
    $ ssh murdock && echo OK!

4a. Now either start the murdock slave manually:

    $ sh murdock-slave-init.sh start

Or install systemd service:

4b. install helper script and systemd service

    $ sudo cp murdock-slave-init.sh /usr/local/bin
    $ sudo cp murdock-slave.service /etc/systemd/system
    $ sudo systemctl daemon-reload
    $ sudo systemctl enable murdock-slave
    $ sudo systemctl start murdock-slave
