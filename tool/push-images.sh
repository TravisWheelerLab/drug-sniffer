#!/usr/bin/env bash

set -e

# Convenience script to push all container images.

IMAGE_REGISTRY=${IMAGE_REGISTRY:-docker.io}
IMAGE_NAMESPACE=${IMAGE_NAMESPACE:-traviswheelerlab}
IMAGE_VERSION=${IMAGE_VERSION:-latest}

pushd containers

for stage in 0*; do
    tag="$IMAGE_REGISTRY/$IMAGE_NAMESPACE/$stage:$IMAGE_VERSION"
    echo "----------------------------------------"
    echo "pushing $tag"
    echo "----------------------------------------"
    pushd "$stage"
    docker push "$tag"
    popd
done

popd
