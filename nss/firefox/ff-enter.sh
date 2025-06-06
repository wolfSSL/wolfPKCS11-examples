#!/bin/bash

set -e

docker build -t ff-docker .

docker run --rm -e DISPLAY=$DISPLAY --network=host -v /tmp/.X11-unix:/tmp/.X11-unix \
	-w /firefox -it ff-docker bash


