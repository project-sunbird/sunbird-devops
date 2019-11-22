#!/bin/bash

# Installing deps
sudo ./install-deps.sh

# installing dbs
# Installing all dbs
echo $INVENTORY_PATH
[[ -z INVENTORY_PATH ]] && echo -e "ERROR: set environment variable \nexport INVENTORY_PATH=/path/to/ansible/inventory" && exit 100

module=Core
# Creating inventory strucure
cp $INVENTORY_PATH/$module/* ../ansible/inventory/env/
ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --skip-tags  postgresql-slave --extra-vars=@config.yml
