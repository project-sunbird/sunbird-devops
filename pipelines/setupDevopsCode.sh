#!/bin/sh

set -ex

COMMIT_REF=${1:-release-1.3}
SUNBIRD_DEVOPS_DIR_NAME=sunbird-devops

XARGS_OPTION_TO_IGNORE_EMPTY=''
if [ `uname` = 'Linux' ]; then
   XARGS_OPTION_TO_IGNORE_EMPTY='--no-run-if-empty'
fi

if [ -d $SUNBIRD_DEVOPS_DIR_NAME ]; then
    cd $SUNBIRD_DEVOPS_DIR_NAME
    git reset --hard && git clean -fd
    git fetch
    git checkout release-1.3
    git pull --all
    git branch --list | grep -v "release-1.3" | xargs $XARGS_OPTION_TO_IGNORE_EMPTY git branch -D
else
    git clone https://github.com/project-sunbird/sunbird-devops.git $SUNBIRD_DEVOPS_DIR_NAME
    cd $SUNBIRD_DEVOPS_DIR_NAME
fi

git checkout $COMMIT_REF
