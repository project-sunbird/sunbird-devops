#!/bin/sh

set -ex

commit_ref=${1}
player_dir=sunbird-portal
if [ ! -d $player_dir ]; then
    git clone https://github.com/project-sunbird/sunbird-portal -b $commit_ref
    exit 0
fi
cd $player_dir
git reset --hard
git clean -fd
git fetch
git checkout "$commit_ref"
git pull -X theirs