#!/usr/bin/env bash

set -e

# Convenience script to test all container images.

pushd containers

for stage in 0*; do
    echo "----------------------------------------"
    echo "testing $stage"
    echo "----------------------------------------"
    pushd "$stage"
    ./build-image.sh
    ./test-image.sh
    popd
done

popd
