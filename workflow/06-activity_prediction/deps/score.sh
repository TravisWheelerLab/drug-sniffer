#!/usr/bin/env bash

set -e

# The parameters below are required. They are described in the pipeline
# documentation.
#
# LIGAND_NAME
# PROTEIN_PDB
# DOCKED_PDBQT
# OUTPUT_PATH

echo "#pose chemical_name gauss_1 gauss_2 repulsion \
hydrophobic non_hydrophobic vdw non_dir_hbond_lj \
non_dir_anti_h_bond_quadratic non_dir_h_bond \
acceptor_acceptor_quadratic donor_donor_quadratic \
electrostatic ad4_solvation ligand_length \
constant_term num_tors_div DFIRE" > "$OUTPUT_PATH"

# Convert the protein to pdbqt
obabel -ipdb "$PROTEIN_PDB" -opdbqt -O "${PROTEIN_PDB}qt"

# Split poses
vina_split --input "$DOCKED_PDBQT" --ligand pose_

pose_id=1
for pose_pdbqt in pose_*.pdbqt; do
    # Create mol2 file
    obabel -ipdbqt "$pose_pdbqt" -omol2 -O "$pose_pdbqt.mol2"

    # Capture DFIRE value
    dfire=$(dligand2-15 -P "$PROTEIN_PDB" -L "$pose_pdbqt" -etype 1)

    # Create all other fields
    smina=$(smina.static -r "${PROTEIN_PDB}qt" -l "$pose_pdbqt" --score_only \
        --custom_scoring /opt/activity_prediction/allterms \
            | grep "##" \
            | sed "s/##//" \
            | awk '{if(NR>1) print}')

    echo "$pose_id $LIGAND_NAME $smina $dfire" >> $OUTPUT_PATH

    let "pose_id=pose_id+1"
done

