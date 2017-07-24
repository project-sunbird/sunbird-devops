#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ANSIBLE_FORCE_COLOR=true ansible-playbook -i ansible/inventory/$ENV ansible/es-backup.yml --tags "es_backup" -vvv --vault-password-file /run/secrets/vault-pass
