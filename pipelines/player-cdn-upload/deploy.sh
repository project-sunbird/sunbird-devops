#!/bin/bash
home_dir=$(pwd)
cd sunbird-devops/ansible
ansible-playbook -c local assets-upload.yml \
    --vault-password-file /run/secrets/vault-pass \
    --extra-vars assets=${home_dir}/sunbird-portal/src/app/dist
