#!/bin/sh

set -ex

commit_ref=${1:-release-1.11}
sunbird_devops_dir_name=sunbird-devops
git -C $sunbird_devops_dir_name fetch --all --tags || git clone https://github.com/project-sunbird/$sunbird_devops_dir_name
cd $sunbird_devops_dir_name
git reset --hard
git clean -fd
git checkout "$commit_ref"
git symbolic-ref HEAD 2>&1 && git pull -X theirs 
