#!/bin/bash

set -e

docker build -t ff-docker .

ARGS="$@"

docker run --rm	-w /firefox ff-docker sh -c "./mach run -- --headless $ARGS"
