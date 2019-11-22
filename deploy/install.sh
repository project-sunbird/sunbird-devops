#!/bin/bash

# Installing deps
sudo ./install-deps.sh

# installing dbs
# Installing all dbs
[[ -z INVENTORY_PATH ]] || echo -e "set environment variable \nINVENTORY_PATH=/path/to/ansible/inventory" && exit 100

# Creating inventory strucure

ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --skip-tags  postgresql-slave --extra-vars=@config.yml
