#!/usr/bin/env bash

set -e

# Required parameters:
#
# DENOVO_LIGANDS_SMI
# DATABASE_ROOT
#
# Optional parameters:
#
# TANIMOTO_CUTOFF

# TODO: Download the database if it isn't there already?

rm -f fingerprints.list
for fingerprint in $DATABASE_ROOT/fingerprints/*.fpt; do
    name="${fingerprint%%.fpt}"
    index="$name.index"
    split="$name.smi"
    echo "$fingerprint" >> fingerprints.list
done

mkdir -p denovo_ligands
mkdir -p denovo_fingerprints
mkdir -p denovo_indexes
mkdir -p dneovo_skips
mkdir -p denovo_neighbors
mkdir -p denovo_splits

denovo_count=0
cat "$DENOVO_LIGANDS_SMI" | while read smi; do
    echo "$smi" > "denovo_ligands/$denovo_count.smi"
    let "denovo_count++"
done

gen_ecfp4_fingerprint.py \
    denovo_ligands \
    denovo_fingerprints \
    denovo_indexes \
    dneovo_skips

for denovo_fingerprint in denovo_fingerprints/*.fpt; do
    filename="${$(basename "$denovo_fingerprint")%%.fpt}.nbrs"
    neighbors \
        "$denovo_fingerprint" \
        fingerprints.list \
        "$TANIMOTO_CUTOFF" \
        > "denovo_neighbors/$filename"
    # Do the perl thing here
done

#    ./neighbors \
#    ~/SARS-CoV2-drugs/pockets/fingerprints/3clpro/fingerprints/Pocket_1.fpt ~/SARS-CoV2-drugs/fingerprinting/db_files.list 100 200 .7
