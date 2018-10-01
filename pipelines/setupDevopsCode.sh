#!/bin/sh

set -ex

commit_ref=${1:-release-1.11}
sunbird_devops_dir_name=sunbird-devops
git -C $sunbird_devops_dir_name pull origin $commit_ref || git clone https://github.com/project-sunbird/sunbird-devops $sunbird_devops_dir_name
cd $sunbird_devops_dir_name
git checkout "$commit_ref"
