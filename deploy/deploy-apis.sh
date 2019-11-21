#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1
# Importing variables
source version.env

ORG=sunbird
ECHO_SERVER_VERSION=0.0.2-silver
ADMIN_UTILS_VERSION=0.0.1-SNAPSHOT-gold

# Onboard APIs
echo "@@@@@@@@@ Onboard APIs"
ansible-playbook -i $INVENTORY_PATH ../ansible/api-manager.yml --tags kong-api --extra-vars kong_admin_api_url=http://localhost:31801 --extra-vars=@config.yml

# Onboard Consumers
echo "@@@@@@@@@ Onboard Consumers"
ansible-playbook -v -i $INVENTORY_PATH ../ansible/api-manager.yml --tags kong-consumer --extra-vars kong_admin_api_url=http://localhost:31801 --extra-vars=@config.yml
