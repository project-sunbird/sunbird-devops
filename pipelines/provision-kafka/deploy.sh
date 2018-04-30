ansible-playbook --version
ansible-playbook -i ansible/inventories/$ENV sunbird-devops/ansible/provision-kafka.yml --vault-password-file /run/secrets/vault-pass
