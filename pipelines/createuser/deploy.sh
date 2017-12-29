#!/bin/sh
pass=`mkpasswd -m sha-512 $sudo_password`
ansible-playbook --version
ansible-playbook -i ansible/inventories/admin sunbird-devops/ansible/createuser.yml --tags "add-user" --extra-vars "remote=bastion-host group=$username user=$username password=$pass public_key=\"$public_key\"" --vault-password-file /run/secrets/vault-pass
ansible-playbook -i ansible/inventories/$ENV sunbird-devops/ansible/createuser.yml --tags "add-user" --extra-vars "remote=$instance_name group=$username user=$username password=$pass public_key=\"$public_key\"" --vault-password-file /run/secrets/vault-pass