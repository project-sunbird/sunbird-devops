#!/bin/sh

set -ex

commit_ref=${1:-release-1.11}
sunbird_devops_dir_name=sunbird-devops
# workaround for fatal: unable to auto-detect email address 
git config --global user.email "jenkins@open-sunbird.org"
git config --global user.name "jenkins"
git -C $sunbird_devops_dir_name pull origin $commit_ref || git clone https://github.com/project-sunbird/sunbird-devops $sunbird_devops_dir_name
cd $sunbird_devops_dir_name
git checkout "$commit_ref"
