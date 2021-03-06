#!/usr/bin/env sh

set -e

# run.sh

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    -e LIGAND_SMI=test.smi \
    -e ADMET_CHECKS="1 2 3" \
    traviswheelerlab/07-admet_prediction \
    run.sh
