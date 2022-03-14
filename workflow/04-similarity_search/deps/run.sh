#!/usr/bin/env bash

set -e

# Required parameters:
#
# DENOVO_LIGANDS_SMI
# MOLECULE_DB
#
# Optional parameters:
#
# TANIMOTO_CUTOFF
# OUTPUT_PATH
#

OUTPUT_PATH=${OUTPUT_PATH:-.}

mkdir -p "$OUTPUT_PATH"

similarity.py \
    -t "$TANIMOTO_CUTOFF" \
    -d "$MOLECULE_DB" \
    -o "$OUTPUT_PATH/" \
    "$DENOVO_LIGANDS_SMI"
