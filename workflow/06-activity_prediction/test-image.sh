#!/usr/bin/env sh

set -e

# cleanup

rm -f test/*.score
rm -f test/pose_*.pdbqt
rm -f test/pose_*.mol2
rm -f test/autodock_output_pose_*.pdbqt

# run.sh

LIGAND_NAME=dummy \
RECEPTOR_PDB=protein.pdb \
DOCKED_PDBQT=autodock_output.pdbqt \
run.sh
