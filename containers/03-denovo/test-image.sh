#!/usr/bin/env bash

set -e

rm -rf test/Run_*

# We can't test this stage properly because we don't have an Autogrow4 test case
# that doesn't take hours to run. In lieu of a proper test, we just confirm that
# the programs we need are available.

# docker run -u $(id -u):$(id -g) -v $PWD/test:/data \
#     -e NUMBER_OF_PROCESSORS=12 \
#     -e RECEPTOR_PATH=/opt/autogrow4/tutorial/PARP/4r6eA_PARP1_prepared.pdb \
#     -e CENTER_X=-37.141998 \
#     -e CENTER_Y=10.206000 \
#     -e CENTER_Z=55.180000 \
#     -e SIZE_X=16.0 \
#     -e SIZE_Y=16.0 \
#     -e SIZE_Z=16.0 \
#     traviswheelerlab/03-denovo \
#     run.sh

docker run -u $(id -u):$(id -g) -v $PWD/test:/data \
    traviswheelerlab/03-denovo \
    which RunAutogrow.py

docker run -u $(id -u):$(id -g) -v $PWD/test:/data \
    traviswheelerlab/03-denovo \
    which dedup.py
