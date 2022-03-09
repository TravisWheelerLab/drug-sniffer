#!/usr/bin/env sh

set -e

# FPADMET

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/07-admet_filtering \
    runadmet.sh -f test.smi -p 1 -a

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/07-admet_filtering \
    java -jar /opt/admet_filtering/JLogP.jar test.smi jlogp.txt
