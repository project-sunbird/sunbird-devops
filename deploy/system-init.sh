#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

[ -f ~/jwt_token_player.txt ] || echo "JWT token (~/jwt_token_player.txt) not found" || exit 1
sunbird_api_auth_token=$(cat ~/jwt_token_player.txt|sed 's/ //g')

# System Initialisation
echo "System Initialisation"
ansible-playbook -i $INVENTORY_PATH ../ansible/system-init.yml --extra-vars=@config.yml --extra-vars "sunbird_api_auth_token=${sunbird_api_auth_token}"
