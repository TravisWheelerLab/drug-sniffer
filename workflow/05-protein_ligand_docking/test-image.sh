#!/usr/bin/env sh

set -e

# autodock.sh
echo "** autodock.sh **"
docker run -v "$PWD/test:/data" -u "$(id -u):$(id -g)" \
    -e RECEPTOR_PDBQT=3clpro_itasser_h.pdbqt \
    -e LIGANDS_SMI=ligands.smi \
    -e CENTER_X=-37.141998 \
    -e CENTER_Y=10.206000 \
    -e CENTER_Z=55.180000 \
    -e SIZE_X=16.0 \
    -e SIZE_Y=16.0 \
    -e SIZE_Z=16.0 \
    traviswheelerlab/05-protein_ligand_docking \
    autodock.sh

