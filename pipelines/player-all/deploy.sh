#!/bin/bash
set -x
home_dir=$(pwd)
env=${1}
# Reading assets directory to upload
assets_dir=${home_dir}/sunbird-portal/src/app/dist
echo $assets_dir
cd sunbird-devops/ansible
ansible-playbook -i ../../ansible/inventories/${env} -c local assets-upload.yml \
    --vault-password-file /home/ops/vault \
    --extra-vars assets=${assets_dir} -v
