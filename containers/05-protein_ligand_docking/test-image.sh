#!/usr/bin/env sh

set -e

rm -f \
    test/docked_ligand.pdbqt \
    test/_ligand.smi \
    test/_ligand.pdbqt \
    test/output.log \
    test/ligand.smi.admet \
    test/ligand.smi.output

docker run -v "$PWD/test:/data" -u "$(id -u):$(id -g)" \
    -e RECEPTOR_PDB=3clpro_rec.pdb \
    -e LIGAND_SMI=ligand.smi \
    -e CENTER_X=-37.141998 \
    -e CENTER_Y=10.206000 \
    -e CENTER_Z=55.180000 \
    -e SIZE_X=16.0 \
    -e SIZE_Y=16.0 \
    -e SIZE_Z=16.0 \
    traviswheelerlab/05-protein_ligand_docking \
    run.sh

