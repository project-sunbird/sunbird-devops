#!/bin/sh
# Build script
# set -o errexit
set -e
ansible-playbook --version
ANSIBLE_FORCE_COLOR=true ansible-playbook -i ansible/inventories/$ENV ansible/es.yml --tags "purge_old_logs" -v --vault-password-file /run/secrets/vault-pass
