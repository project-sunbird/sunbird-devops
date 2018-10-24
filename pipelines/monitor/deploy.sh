#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
pwd
ansible-playbook -i ansible/inventories/${TARGET_ENV} sunbird-devops/ansible/monitoring.yml --vault-password-file /run/secrets/vault-pass 
