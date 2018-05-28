#!/bin/sh
# Build script
# set -o errexit

env=${ENV:-null}



ansible-playbook --version
ansible-playbook -i ansible/inventories/$env sunbird-devops/ansible/jmeter-deploy.yml --vault-password-file /run/secrets/vault-pass -v
