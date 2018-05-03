ansible-playbook --version
ansible-playbook -i ansible/inventories/$ENV sunbird-devops/ansible/provision-secor.yml --vault-password-file /run/secrets/vault-pass
