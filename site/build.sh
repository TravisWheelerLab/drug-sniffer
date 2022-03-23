#!/usr/bin/env bash

set -eou pipefail

docker build -t drug-sniffer-site .
docker run -v "$PWD":/data -u $(id -u):$(id -g) \
    drug-sniffer-site \
    make html

rm -rf ../docs
cp -R build/html ../docs

touch ../docs/.nojekyll
echo -n 'drugsniffer.org' > ../docs/CNAME

