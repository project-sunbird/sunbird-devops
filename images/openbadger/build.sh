#!/bin/bash
# Build script
set -eo pipefail
build_tag=$1
name=badger
node=$2
org=$3

docker build -f ./images/openbadger/Dockerfile -t ${org}/${name}:${build_tag} .
echo {\"image_name\" : \"${name}\", \"image_tag\" : \"${build_tag}\", \"node_name\" : \"$node\"} > metadata.json
