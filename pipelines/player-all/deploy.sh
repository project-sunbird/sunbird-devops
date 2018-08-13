#!/bin/bash
home_dir=$(pwd)
env=${1}
[[ -d app_dist ]] && rm -rf app_dist 
tar -xvf player-dist.tar.gz
buildHash=$(grep buildHash app_dist/package.json | cut -d '"' -f4)
releaseNumber=$(grep version app_dist/package.json | cut -d '"' -f4)
head app_dist/package.json
# Renaming index.ejs to index.release-version.buildHash.ejs
mv app_dist/dist/index.ejs app_dist/dist/index.${releaseNumber}.${buildHash}.ejs
# Reading assets directory to upload
assets_dir=$(readlink -f app_dist/dist)
echo $assets_dir
ls app_dist/dist/index*
cd sunbird-devops/ansible
ansible-playbook -i ../../ansible/inventories/${env} -c local assets-upload.yml \
    --vault-password-file /home/ops/vault \
    --extra-vars assets=${assets_dir}

