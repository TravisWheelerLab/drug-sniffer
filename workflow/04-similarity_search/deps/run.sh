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
#

similarity.py \
    -t "$TANIMOTO_CUTOFF" \
    -d "$MOLECULE_DB" \
    "$DENOVO_LIGANDS_SMI" > db_ligands.smi
