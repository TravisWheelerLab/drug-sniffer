#!/usr/bin/env bash

# Required parameters - the parameters in the first group should be the same
# values provided to stage 3.
#
# RECEPTOR_PDBQT
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

n=0
cat "$LIGANDS_SMI" | while read smi
do
    echo "processing $smi"
    echo "$smi" > ligand.smi
    obabel -ismi ligand.smi -opdbqt -O ligand.pdbqt --gen3d
    if [[ "$?" -eq 0 ]]; then
        vina --receptor "$RECEPTOR_PDBQT" \
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
        if [[ "$?" -ne 0 ]]; then
            echo "vina error processing $smi"
        fi
        let "n=n+1"
    else
        echo "obabel error processing $smi"
    fi
    rm -f ligand.smi ligand.pdbqt
done

