#!/usr/bin/env bash

# Required parameters - the parameters in the first group should be the same
# values provided to stage 3.
#
# RECEPTOR_PDB
# LIGANDS_SMI
# CENTER_X
# CENTER_Y
# CENTER_Z
# SIZE_X
# SIZE_Y
# SIZE_Z
#
# Optional parameters
#
# NUMBER_OF_POSES

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
    -r "$RECEPTOR_PDB" -o receptor.pdbqt -A hydrogens
exit-error "$?" "receptor pdb to pdbqt"

n=0
cat "$LIGANDS_SMI" | while read smi
do
    echo "docking $smi"
    echo "$smi" > ligand.smi
    obabel -ismi ligand.smi -opdbqt -O ligand.pdbqt --gen3d --ff UFF
    if [ "$?" != "0" ]; then
        log-error "$?" "convert ligand $smi to pdbqt"
        let "n=n+1"
        continue
    fi

    vina --receptor receptor.pdbqt \
        --ligand ligand.pdbqt \
        --center_x $CENTER_X \
        --center_y $CENTER_Y \
        --center_z $CENTER_Z \
        --size_x $SIZE_X \
        --size_y $SIZE_Y \
        --size_z $SIZE_Z \
        --out docked_${n}.pdbqt \
        --num_modes "$NUMBER_OF_POSES" \
        --log output.log \
        --exhaustiveness 4
    if [ "$?" != "0" ]; then
        log-error "$?" "dock ligand $smi"
        let "n=n+1"
        continue
    fi

    let "n=n+1"
done

rm -f ligand.smi ligand.pdbqt
rm -f receptor.pdbqt
