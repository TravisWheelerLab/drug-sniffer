#!/usr/bin/env bash

set -e

make html
rm -rf ../docs
cp -R build/html ../docs
touch ../docs/.nojekyll
echo -n 'drugsniffer.org' > ../docs/CNAME

