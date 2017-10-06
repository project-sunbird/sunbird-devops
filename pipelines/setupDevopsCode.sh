#!/bin/sh

set -ex

rm -rf sunbird-devops
git -C sunbird-devops pull || git clone https://github.com/project-sunbird/sunbird-devops.git sunbird-devops

# Temp line to remove folder till it is removed from code here
ls -al
rm -rf ansible/roles ansible/*.yml ansible/static-files ansible/group_vars ansible/inventory ansible/secrets
ls -al
