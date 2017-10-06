#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ANSIBLE_FORCE_COLOR=true ansible-playbook -i ansible/inventories/$ENV sunbird-devops/ansible/ops.yml --limit '!localhost' --tags "metrics-exporter" -v --vault-password-file /run/secrets/vault-pass
