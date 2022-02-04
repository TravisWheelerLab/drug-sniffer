#!/usr/bin/env sh

set -e

# FPADMET

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/07-admet_filtering \
    runadmet.sh -f test.smi -p 1 -a

