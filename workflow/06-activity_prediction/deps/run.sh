#!/usr/bin/env bash

set -e

# Required parameters
#
# The parameters below are required. They are described in the pipeline
# documentation.
#
# LIGAND_NAME
# RECEPTOR_PDB
# DOCKED_PDBQT
#
# Full output will end up in OUTPUT_PATH
#
# Optional parameters
#
# OUTPUT_PATH
#

OUTPUT_PATH="${OUTPUT_PATH:-ligand.score}"

echo "#pose chemical_name gauss_1 gauss_2 repulsion \
hydrophobic non_hydrophobic vdw non_dir_hbond_lj \
non_dir_anti_h_bond_quadratic non_dir_h_bond \
acceptor_acceptor_quadratic donor_donor_quadratic \
electrostatic ad4_solvation ligand_length \
constant_term num_tors_div DFIRE" > "${OUTPUT_PATH}_"

# Convert the protein to pdbqt
obabel -ipdb "$RECEPTOR_PDB" -opdbqt -O "receptor.pdbqt"

# Split poses
vina_split --input "$DOCKED_PDBQT" --ligand pose_

pose_id=1
for pose_pdbqt in pose_*.pdbqt; do
    # Create mol2 file
    obabel -ipdbqt "$pose_pdbqt" -omol2 -O "$pose_pdbqt.mol2"

    # Capture DFIRE value
    dfire=$(dligand2-15 -P "$RECEPTOR_PDB" -L "$pose_pdbqt.mol2" -etype 1)

    # Create all other fields
    smina=$(smina.static -r "receptor.pdbqt" -l "$pose_pdbqt" --score_only \
        --custom_scoring /opt/activity_prediction/allterms \
            | grep "##" \
            | sed "s/##//" \
            | awk '{if(NR>1) print}')

    echo "$pose_id $LIGAND_NAME $smina $dfire" >> "${OUTPUT_PATH}_"

    let "pose_id=pose_id+1"
done

# Re-score with the ML model
rescore.py /opt/activity_prediction/platstd.h5 "${OUTPUT_PATH}_" \
    > "$OUTPUT_PATH"

rm -f receptor.pdbqt

