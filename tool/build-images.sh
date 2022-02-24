#!/usr/bin/env bash

set -e

# Convenience script to build all container images.

IMAGE_REGISTRY=${IMAGE_REGISTRY:-docker.io}
IMAGE_NAMESPACE=${IMAGE_NAMESPACE:-traviswheelerlab}
IMAGE_VERSION=${IMAGE_VERSION:-latest}

for stage in workflow/0*; do
    echo "----------------------------------------"
    echo "building $IMAGE_REGISTRY/$IMAGE_NAMESPACE/$stage:$IMAGE_VERSION"
    echo "----------------------------------------"
    pushd "$stage"
    ./build-image.sh
    popd
done
