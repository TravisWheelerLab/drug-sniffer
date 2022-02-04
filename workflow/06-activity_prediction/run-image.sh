#!/usr/bin/env sh

set -e

docker run -it -u $(id -u):$(id -g) -v "$PWD":/data \
    traviswheelerlab/06-activity_prediction:latest bash

