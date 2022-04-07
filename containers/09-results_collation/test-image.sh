#!/usr/bin/env sh

set -e

# process_errors.py

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/09-results_collation \
    process_results.py \
        --ligand-smi "ligand.smi" \
        --ligand-score "score.txt" \
        --admet-output "admet.txt" \
        --admet-checks "1"
