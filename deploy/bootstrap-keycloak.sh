#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

#Deploy keycloak
echo "@@@@@@@@@ Keycloak "
ansible-playbook -i $INVENTORY_PATH ../ansible/keycloak.yml -c local --tags keycloak-bootstrap --extra-vars=@config.yml
