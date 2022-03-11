#!/usr/bin/env bash

set -e

# Convenience script to build all container images.

IMAGE_REGISTRY=${IMAGE_REGISTRY:-}
IMAGE_NAMESPACE=${IMAGE_NAMESPACE:-traviswheelerlab}
IMAGE_VERSION=${IMAGE_VERSION:-latest}

pushd workflow

for stage in 0*; do
    tag="$IMAGE_REGISTRY/$IMAGE_NAMESPACE/$stage:$IMAGE_VERSION"
    echo "----------------------------------------"
    echo "building $tag"
    echo "----------------------------------------"
    pushd "$stage"
    docker build -t "$tag" .
    popd
done

popd
