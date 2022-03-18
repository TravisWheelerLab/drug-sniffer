#!/usr/bin/env sh

set -e

# process_errors.py

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/09-results_collation \
    process_errors.py \
        --ligand-score score.txt \
        --admet-output admet.txt
