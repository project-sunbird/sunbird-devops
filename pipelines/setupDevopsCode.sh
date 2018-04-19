#!/bin/sh

set -ex

commit_ref=${1:-release-1.5.2}
sunbird_devops_dir_name=sunbird-devops

xargs_option_to_ignore_empty=''
if [ `uname` = 'Linux' ]; then
   xargs_option_to_ignore_empty='--no-run-if-empty'
fi

if [ -d $sunbird_devops_dir_name ]; then
    cd $sunbird_devops_dir_name
    git reset --hard && git clean -fd
    git fetch
    git checkout $commit_ref
    git branch --list | grep -v "$commit_ref" | xargs $xargs_option_to_ignore_empty git branch -D
else
    git clone https://github.com/project-sunbird/sunbird-devops.git $sunbird_devops_dir_name
    cd $sunbird_devops_dir_name
fi

git checkout "$commit_ref"
