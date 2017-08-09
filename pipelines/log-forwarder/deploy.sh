#!/bin/sh
# Build script
# set -o errexit

ansible-playbook --version
ANSIBLE_FORCE_COLOR=true ansible-playbook -i ansible/inventory/$ENV ansible/ops.yml --tags "log-forwarder" -v --vault-password-file /run/secrets/vault-pass
