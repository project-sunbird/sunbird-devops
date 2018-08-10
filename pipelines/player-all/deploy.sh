#!/bin/bash
home_dir=$(pwd)
env=${1}
[[ -d app_dist ]] && rm -rf app_dist 
tar -xvf player-build.tar.gz
head app_dist/package.json
ls app_dist/dist/index*
cd sunbird-devops/ansible
ansible-playbook -i ../../ansible/inventories/${env} -c local assets-upload.yml \
    --vault-password-file /home/ops/vault \
    --extra-vars assets=${home_dir}/sunbird-portal/src/app/dist -v
