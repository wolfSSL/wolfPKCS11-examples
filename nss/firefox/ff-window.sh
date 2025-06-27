#!/bin/bash

set -e

docker build -t ff-docker .

ARGS="$@"

xhost local:root

docker run --rm -e DISPLAY=$DISPLAY --network=host -v /tmp/.X11-unix:/tmp/.X11-unix \
	-w /home/ubuntu/firefox ff-docker sh -c "./mach run -- $ARGS"


