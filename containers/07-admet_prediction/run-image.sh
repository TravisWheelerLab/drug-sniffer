#!/usr/bin/env sh

set -e

docker run -it -v "$PWD":/data -u $(id -u):$(id -g) \
    traviswheelerlab/07-admet_prediction:latest bash

