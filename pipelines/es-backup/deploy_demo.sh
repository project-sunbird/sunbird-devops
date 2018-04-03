#!/bin/sh
# Build script
# set -o errexit
set -e
ansible-playbook --version
ANSIBLE_FORCE_COLOR=true ansible-playbook -i ansible/inventories/$ENV sunbird-devops/ansible/es.yml --tags "es_backup" -v --vault-password-file /home/ops/vault
