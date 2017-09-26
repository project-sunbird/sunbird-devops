#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

ORG=sunbird
KEYCLOAK_VERSION=3.2.1.Final-bronze

# Create application network
echo "@@@@@@@@@ Keycloak deploy"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-keycloak1" --extra-vars "deploy_keycloak1=true hub_org=${ORG} image_name=keycloak_image image_tag=$KEYCLOAK_VERSION service_name=keycloak1"
