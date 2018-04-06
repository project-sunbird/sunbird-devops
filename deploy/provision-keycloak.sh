#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

#Keycloak installation
echo "@@@@@@@@@ Keycloak "
ansible-playbook -i $INVENTORY_PATH ../ansible/keycloak.yml --tags provision --extra-vars=@config
