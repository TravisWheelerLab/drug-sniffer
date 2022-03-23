#!/usr/bin/env sh

set -e

rm -f test/docked_*.pdbqt test/ligand.* test/output.log test/admet.smi

docker run -v "$PWD/test:/data" -u "$(id -u):$(id -g)" \
    -e RECEPTOR_PDB=3clpro_rec.pdb \
    -e LIGANDS_SMI=ligands.smi \
    -e CENTER_X=-37.141998 \
    -e CENTER_Y=10.206000 \
    -e CENTER_Z=55.180000 \
    -e SIZE_X=16.0 \
    -e SIZE_Y=16.0 \
    -e SIZE_Z=16.0 \
    traviswheelerlab/05-protein_ligand_docking \
    run.sh

