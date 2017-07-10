#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ansible-playbook -i ansible/inventory/dev ansible/deploy.yml --tags "stack-api-manager"
