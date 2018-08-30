#!/bin/bash
home_dir=$(pwd)
env=${1}
cd sunbird-devops/ansible
ansible-playbook -i ../../ansible/inventories/${env} -c local assets-upload.yml \
    --vault-password-file /home/ops/vault \
    --extra-vars "player_cdn_container=tenants" \
    --extra-vars assets=${home_dir}/sunbird-portal/src/app/tenants-build -v