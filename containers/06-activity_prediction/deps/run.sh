#!/usr/bin/env bash

# Required parameters:
#
# RECEPTOR_PDB
# DOCKED_PDBQT
#
# Output:
#
# ligand.score
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

echo "#pose gauss_1 gauss_2 repulsion \
hydrophobic non_hydrophobic vdw non_dir_hbond_lj \
non_dir_anti_h_bond_quadratic non_dir_h_bond \
acceptor_acceptor_quadratic donor_donor_quadratic \
electrostatic ad4_solvation ligand_length \
constant_term num_tors_div DFIRE" > _ligand.score

# Convert the protein to pdbqt
obabel -ipdb "$RECEPTOR_PDB" -opdbqt -O _receptor.pdbqt
exit-error "$?" "failed converting receptor to pdbqt"

# Split poses
vina_split --input "$DOCKED_PDBQT" --ligand _pose_
exit-error "$?" "failed running vina_split: $DOCKED_PDBQT"

pose_id=0
for pose_pdbqt in _pose_*.pdbqt; do
    # Create mol2 file
    obabel -ipdbqt "$pose_pdbqt" -omol2 -O "$pose_pdbqt.mol2"
    if [ "$?" != "0" ]; then
        log-error "$?" "failed converting pose to mol2: $pose_pdbqt"
        continue
    fi

    # Capture DFIRE value
    dfire=$(dligand2-15 -P "$RECEPTOR_PDB" -L "$pose_pdbqt.mol2" -etype 1)
    if [ "$?" != "0" ]; then
        log-error "$?" "failed running dfire: $pose_pdbqt"
        continue
    fi

    # Create all other fields
    smina=$(smina.static -r _receptor.pdbqt -l "$pose_pdbqt" --score_only \
        --custom_scoring /opt/activity_prediction/allterms \
            | grep "##" \
            | sed "s/##//" \
            | awk '{if(NR>1) print}')
    if [ "$?" != "0" ]; then
        log-error "$?" "failed running smina: $pose_pdbqt"
        continue
    fi

    let "pose_id=pose_id+1"
    echo "$pose_id $smina $dfire" >> _ligand.score
done

# If we never incremented the pose ID, then we know that none of the poses
# worked and we need to fail the whole ligand
if [ "$pose_id" == "0" ]; then
    exit-error "1" "failed creating poses: $DOCKED_PDBQT"
fi

# Re-score with the ML model
dock2bind.py /opt/activity_prediction/platstd.h5 _ligand.score \
    > ligand.score
exit-error "$?" "failed running dock2bind model"

rm -f _receptor.pdbqt _pose_*.pdbqt
