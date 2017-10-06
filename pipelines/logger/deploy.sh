#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version

ansible-playbook -i ansible/inventories/${ENV} sunbird-devops/ansible/logging.yml --vault-password-file  /run/secrets/vault-pass
