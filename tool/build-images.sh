#!/usr/bin/env bash

set -e

# Convenience script to build all container images.

IMAGE_REGISTRY=${IMAGE_REGISTRY:-docker.io}
IMAGE_NAMESPACE=${IMAGE_NAMESPACE:-traviswheelerlab}
IMAGE_VERSION=${IMAGE_VERSION:-latest}

for stage in workflow/0*; do
    echo $IMAGE_REGISTRY
    echo $IMAGE_NAMESPACE
    echo $IMAGE_VERSION
    pushd "$stage"
    ./build-image.sh
    popd
done
