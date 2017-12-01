#!/bin/sh
pass=`mkpasswd -m sha-512 $3`
ansible-playbook --version
ansible-playbook -i ansible/inventories/admin sunbird-devops/ansible/createuser.yml --tags "add-user" --extra-vars "remote=bastion-host group=$2 user=$2 password=$pass public_key=$4" --vault-password-file /run/secrets/vault-pass
ansible-playbook -i ansible/inventories/$ENV sunbird-devops/ansible/createuser.yml --tags "add-user" --extra-vars "remote=$1 group=$2 user=$2 password=$pass public_key=$4" --vault-password-file /run/secrets/vault-pass