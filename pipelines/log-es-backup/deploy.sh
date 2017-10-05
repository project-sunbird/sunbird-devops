#!/bin/sh
# Build script
# set -o errexit
set -e
ansible-playbook --version
ANSIBLE_FORCE_COLOR=true ansible-playbook -i ansible/inventories/$ENV ansible/es.yml --tags "log_es_backup" -v --vault-password-file /run/secrets/vault-pass
