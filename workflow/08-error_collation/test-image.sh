#!/usr/bin/env sh

set -e

# process_errors.py

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/08-error_collation \
    process_errors.py \
        --activity-prediction ap_log.txt \
        --protein-ligand-docking pld_log.txt
