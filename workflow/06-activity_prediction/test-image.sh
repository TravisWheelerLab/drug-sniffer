#!/usr/bin/env sh

set -e

# cleanup

rm -f test/*.score
rm -f test/pose_*.pdbqt
rm -f test/pose_*.mol2
rm -f test/autodock_output_pose_*.pdbqt

# vina_split

echo "** vina_split **"
docker run -v "$PWD"/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/06-activity_prediction \
    vina_split --input autodock_output.pdbqt --ligand autodock_output_pose_

# obabel - mol2

echo "** obabel - mol2 **"
docker run -v "$PWD"/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/06-activity_prediction \
    obabel -ipdbqt autodock_output_pose_1.pdbqt -omol2 \
    -O autodock_output_pose_1.mol2

# dligand2

echo "** dligand2 **"
docker run -v "$PWD"/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/06-activity_prediction \
    dligand2-15 -P protein.pdb -L autodock_output_pose_1.mol2 -etype 1

# smina

echo "** smina **"
docker run -v "$PWD"/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/06-activity_prediction \
    smina.static -r protein.pdb -l autodock_output_pose_1.pdbqt \
        --score_only --custom_scoring /opt/activity_prediction/allterms

# score.sh

echo "** score.sh **"
docker run -v "$PWD"/test:/data -u $(id -u):$(id -g) \
    -e LIGAND_NAME=test \
    -e PROTEIN_PDB=protein.pdb \
    -e DOCKED_PDBQT=autodock_output.pdbqt \
    -e OUTPUT_PATH=autodock_output.score \
    traviswheelerlab/06-activity_prediction \
    score.sh
cat test/autodock_output.score

# rescore.py

echo "** rescore.py **"
docker run -v "$PWD"/test:/data -u $(id -u):$(id -g) \
    traviswheelerlab/06-activity_prediction \
    rescore.py /opt/activity_prediction/platstd.h5 autodock_output.score

