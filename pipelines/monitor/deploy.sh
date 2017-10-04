#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ansible-playbook -i ansible/inventories/${TARGET_ENV} ansible/monitoring.yml -v --vault-password-file /run/secrets/vault-pass
