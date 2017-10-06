#!/bin/sh
set -e
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}

env=${ENV:-null}

echo "env:            ${env}"

ansible-playbook -i ansible/inventories/$ENV sunbird-devops/ansible/jenkins-slave.yml --tags "documentation-jenkins-slave" --vault-password-file /run/secrets/vault-pass
