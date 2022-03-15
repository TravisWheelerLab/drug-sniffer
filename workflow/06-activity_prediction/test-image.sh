#!/usr/bin/env sh

set -e

# cleanup

rm -f test/*.score
rm -f test/pose_*.pdbqt
rm -f test/pose_*.mol2
rm -f test/autodock_output_pose_*.pdbqt

# run.sh

docker run -v $PWD/test:/data -u $(id -u):$(id -g) \
    -e LIGAND_NAME=dummy \
    -e RECEPTOR_PDB=protein.pdb \
    -e DOCKED_PDBQT=autodock_output.pdbqt \
    traviswheelerlab/06-activity_prediction:latest \
    run.sh
