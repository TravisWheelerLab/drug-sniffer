#!/usr/bin/env sh

set -e

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    -e DENOVO_LIGANDS_SMI=denovo.smi \
    -e MOLECULE_DB=. \
    -e TANIMOTO_CUTOFF=0.5 \
    -e OUTPUT_PATH=/data/output \
    traviswheelerlab/04-similarity_search \
    run.sh
