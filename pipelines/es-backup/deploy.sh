#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ansible-playbook -i ansible/inventory/$ENV ansible/es-backup.yml --tags "es_backup" --vault-password-file /run/secrets/vault-pass
