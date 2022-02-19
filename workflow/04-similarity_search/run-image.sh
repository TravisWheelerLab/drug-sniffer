#!/usr/bin/env sh

set -e

docker run -it -v $PWD:/data -u $(id -u):$(id -g) \
    traviswheelerlab/04-similarity_search bash

