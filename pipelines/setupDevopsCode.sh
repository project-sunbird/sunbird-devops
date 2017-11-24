#!/bin/sh

set -ex

COMMIT_REF=${1:-master}
SUNBIRD_DEVOPS_DIR_NAME=sunbird-devops

if [ -d $SUNBIRD_DEVOPS_DIR_NAME ]; then
    cd $SUNBIRD_DEVOPS_DIR_NAME
    git reset --hard && git clean -fd
    git checkout master
    git pull --all
    git branch | grep -v "master" | xargs git branch -D
else
    git clone https://github.com/project-sunbird/sunbird-devops.git $SUNBIRD_DEVOPS_DIR_NAME
    cd $SUNBIRD_DEVOPS_DIR_NAME
fi

git checkout $COMMIT_REF
