#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ANSIBLE_FORCE_COLOR=true ansible-playbook -i ansible/inventories/$ENV sunbird-devops/ansible/es.yml --tags "log_es_restore" --extra-vars "snapshot_number=$SNAPSHOT_NUMBER" -v --vault-password-file /run/secrets/vault-pass
