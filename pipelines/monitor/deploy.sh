#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ansible-playbook -i ansible/inventory/${TARGET_ENV} ansible/deploy.yml --tags "stack-monitor" --vault-password-file /run/secrets/vault-pass
