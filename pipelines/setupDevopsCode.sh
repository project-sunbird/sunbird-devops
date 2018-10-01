#!/bin/sh

set -ex

commit_ref=${1:-release-1.10.1}
sunbird_devops_dir_name=sunbird-devops
git -C $sunbird_devops_dir_name pull origin $commit_ref || git clone https://github.com/project-sunbird/sunbird-devops $sunbird_devops_dir_name
# workaround for fatal: unable to auto-detect email address 
git config --global user.email "jenkins@open-sunbird.org"
git config --global user.name "jenkins"
cd $sunbird_devops_dir_name
git checkout "$commit_ref"
