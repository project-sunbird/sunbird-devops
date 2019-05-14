#!/bin/sh
# Build script
# set -o errexit
build_tag=$1
node=$2
hub_org=$3
name=kong
docker build -f Dockerfile -t ${hub_org}/${name}:${build_tag} .
echo {\"image_name\" : \"${name}\", \"image_tag\" : \"${build_tag}\", \"node_name\" : \"$node\"} > metadata.json
