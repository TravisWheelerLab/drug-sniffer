#!/usr/bin/env sh

set -e

# FPADMET

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/07-admet_filtering \
    runadmet.sh -f test.smi -p 1 -a

# JLogP

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/07-admet_filtering \
    java -jar /opt/JLogP/build/JLogP.jar test.smi jlogp.txt

# run.sh

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    -e LIGANDS_SMI=test.smi \
    -e ADMET_CHECKS="1 2 3" \
    traviswheelerlab/07-admet_filtering \
    run.sh
