# wolfPCKS11 in Firefox

## Introduction

This builds Firefox with wolfPKCS11 as the crypto backend for NSS. Making all
TLS connections in Firefox use wolfSSL.

Note that the Docker build for this will require ~1GB of RAM per CPU core and
will take a long time to build.

## Scripts

There are three scripts in this directory. All of them create debug builds, so
performance will not be fantastic, but it is easier to see what is going on
inside.

Every script will build the Docker image (which will be skipped if it has
already been built), before executing.

### ff-window.sh

This is intended to be run on a Linux host. It build and run Firefox inside a
Docker image with wolfPKCS11 and use Xorg to show the Firefox window. This has
been made compatible with Wayland hosts too.

### ff-cli.sh

This runs Firefox in headless mode.

### ff-enter.sh

This gives you a BASH prompt inside the Docker image once it has been built,
so that it can be inspected and executed manually.
