#!/bin/sh

set -ex

echo $(pwd)
commit_ref=${1}
build_hash=$(jq '.commitHash' metadata.json | sed 's/\"//g')
player_dir=sunbird-portal
git -C sunbird-portal fetch --all --tags || git clone https://github.com/project-sunbird/sunbird-portal -b ${commit_ref}
cd sunbird-portal
git checkout -f "$build_hash" .
