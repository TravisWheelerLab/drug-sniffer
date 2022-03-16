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

function log-error {
    local code="$1"
    local msg="$2"
    echo "exited with code $code: $msg" >> errors.log
}

function exit-error {
    local code="$1"
    local msg="$2"
    if [ "$code" != "0" ]; then
        log-error "$code" "$msg"
        exit "$code"
    fi
}

touch errors.log

OUTPUT_PATH="${OUTPUT_PATH:-ligand.score}"

echo "#pose chemical_name gauss_1 gauss_2 repulsion \
hydrophobic non_hydrophobic vdw non_dir_hbond_lj \
non_dir_anti_h_bond_quadratic non_dir_h_bond \
acceptor_acceptor_quadratic donor_donor_quadratic \
electrostatic ad4_solvation ligand_length \
constant_term num_tors_div DFIRE" > "${OUTPUT_PATH}_"

# Convert the protein to pdbqt
obabel -ipdb "$RECEPTOR_PDB" -opdbqt -O "receptor.pdbqt"
exit-error "$?" "convert receptor to pdbqt"

# Split poses
vina_split --input "$DOCKED_PDBQT" --ligand pose_
exit-error "$?" "run vina_split on $DOCKED_PDBQT"

pose_id=1
for pose_pdbqt in pose_*.pdbqt; do
    # Create mol2 file
    obabel -ipdbqt "$pose_pdbqt" -omol2 -O "$pose_pdbqt.mol2"
    if [ "$?" != "0" ]; then
        log-error "$?" "convert pose $pose_pdbqt to mol2"
        continue
    fi

    # Capture DFIRE value
    dfire=$(dligand2-15 -P "$RECEPTOR_PDB" -L "$pose_pdbqt.mol2" -etype 1)
    if [ "$?" != "0" ]; then
        log-error "$?" "run dfire on $pose_pdbqt"
        continue
    fi

    # Create all other fields
    smina=$(smina.static -r "receptor.pdbqt" -l "$pose_pdbqt" --score_only \
        --custom_scoring /opt/activity_prediction/allterms \
            | grep "##" \
            | sed "s/##//" \
            | awk '{if(NR>1) print}')
    if [ "$?" != "0" ]; then
        log-error "$?" "run smina on $pose_pdbqt"
        continue
    fi

    echo "$pose_id $LIGAND_NAME $smina $dfire" >> "${OUTPUT_PATH}_"

    let "pose_id=pose_id+1"
done

# Re-score with the ML model
rescore.py /opt/activity_prediction/platstd.h5 "${OUTPUT_PATH}_" \
    > "$OUTPUT_PATH"
exit-error "$?" "run rescore model"

rm -f receptor.pdbqt
