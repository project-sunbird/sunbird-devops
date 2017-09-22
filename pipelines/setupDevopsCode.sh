#!/bin/sh

set -ex

git -C sunbird-devops pull || git clone https://github.com/project-sunbird/sunbird-devops.git sunbird-devops

# Temp line to remove folder till it is removed from code here
ls -al
rm -rf ansible/roles ansible/*.yml ansible/static-files
rm -rf sunbird-devops/ansible/inventory sunbird-devops/ansible/group_vars

cp -r sunbird-devops/ansible/* ansible/