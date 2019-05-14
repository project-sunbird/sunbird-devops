#!/bin/sh
# Build script
# set -o errexit
name=kong
docker build -f ./images/kong/Dockerfile -t ${hub_org}/${name}:${build_tag} .
echo {\"image_name\" : \"${name}\", \"image_tag\" : \"${build_tag}\", \"node_name\" : \"$node\"} > metadata.json
