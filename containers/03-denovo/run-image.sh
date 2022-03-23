#!/usr/bin/env sh

set -e

docker run -it -u $UID:$GID -v $PWD:/data \
    traviswheelerlab/03-denovo:latest bash

