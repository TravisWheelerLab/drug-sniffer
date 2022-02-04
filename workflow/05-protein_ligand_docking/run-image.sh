#!/usr/bin/env sh

set -e

docker run -it -v "$PWD":/data -u $(id -u):$(id -g) \
    traviswheelerlab/05-protein_ligand_docking bash

