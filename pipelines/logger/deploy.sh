#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version

ansible-playbook -i ansible/inventories/${ENV} sunbird-devops/ansible/deploy.yml --tags "stack-logger" --vault-password-file  /run/secrets/vault-pass
