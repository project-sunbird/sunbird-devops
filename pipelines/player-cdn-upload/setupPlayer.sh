#!/bin/sh

set -ex

commit_ref=${1:-angular-migration}
player_dir=sunbird-portal
[ -d $player_dir ] || git clone https://github.com/project-sunbird/sunbird-player -b $commit_ref && exit 0
cd $player_dir
git reset --hard
git clean -fd
git fetch
git checkout "$commit_ref"
git pull -X theirs
