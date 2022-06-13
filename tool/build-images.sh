#!/usr/bin/env bash

set -e

# Convenience script to build all container images.

IMAGE_PUSH=${IMAGE_PUSH:-0}

IMAGE_NAMESPACE=${IMAGE_NAMESPACE:-traviswheelerlab}
IMAGE_VERSION=${IMAGE_VERSION:-latest}

pushd containers

for stage in 0*; do
    tag="$IMAGE_NAMESPACE/$stage:$IMAGE_VERSION"
    echo "----------------------------------------"
    echo "building $tag"
    echo "----------------------------------------"
    pushd "$stage"
    docker build -t "$tag" .
    
    if [[ "$IMAGE_PUSH" != "0" ]]; then
        echo "----------------------------------------"
        echo "pushing $tag"
        echo "----------------------------------------"
        docker push "$tag"
    fi
    popd
done

popd

