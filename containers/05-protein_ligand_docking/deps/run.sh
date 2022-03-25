#!/usr/bin/env bash

# Required parameters - the parameters in the first group should be the same
# values provided to stage 3:
#
# RECEPTOR_PDB
# CENTER_X
# CENTER_Y
# CENTER_Z
# SIZE_X
# SIZE_Y
# SIZE_Z
#
# LIGAND_SMI
#
# Optional parameters:
#
# NUMBER_OF_POSES
#
# Outputs:
#
# docked_ligand.pdbqt
# ligand.smi.admet
# ligand.smi.output
# errors.log
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

NUMBER_OF_POSES=${NUMBER_OF_POSES:-4}

/opt/mgltools/bin/pythonsh \
    /opt/mgltools/MGLToolsPckgs/AutoDockTools/Utilities24/prepare_receptor4.py \
    -r "$RECEPTOR_PDB" -o _receptor.pdbqt -A hydrogens
exit-error "$?" "converting receptor to pdbqt failed"

smi=$(cat "$LIGAND_SMI")
echo "docking $smi"
echo "$smi" > _ligand.smi

obabel -ismi _ligand.smi -opdbqt -O _ligand.pdbqt --gen3d --ff UFF
exit-error "$?" "converting ligand to pdbqt failed: $smi"

vina --receptor _receptor.pdbqt \
    --ligand _ligand.pdbqt \
    --center_x $CENTER_X \
    --center_y $CENTER_Y \
    --center_z $CENTER_Z \
    --size_x $SIZE_X \
    --size_y $SIZE_Y \
    --size_z $SIZE_Z \
    --out docked_ligand.pdbqt \
    --num_modes "$NUMBER_OF_POSES" \
    --log output.log \
    --exhaustiveness 4 \
    --seed 42
exit-error "$?" "docking ligand failed: $smi"

# Successfully processed the ligand so add it to the lists for
# ADMET prediction and output
echo "$smi" > ligand.smi.admet
echo "$smi" > ligand.smi.output

rm -f _ligand.smi _ligand.pdbqt
rm -f _receptor.pdbqt
