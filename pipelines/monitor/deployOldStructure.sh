#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ansible-playbook -i ansible/inventory/${TARGET_ENV} ansible/monitoring.yml --vault-password-file /run/secrets/vault-pass
