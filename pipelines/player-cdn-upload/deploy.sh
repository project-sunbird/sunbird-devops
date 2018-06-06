#!/bin/bash
home_dir=$(pwd)
cd sunbird-devops/ansible
ansible-playbook -i ../../ansible/inventories/dev -c local assets-upload.yml \
    --vault-password-file /home/ops/vault \
    --extra-vars assets=${home_dir}/sunbird-portal/src/app/dist
