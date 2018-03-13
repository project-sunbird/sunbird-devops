#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

ORG=sunbird
ECHO_SERVER_VERSION=0.0.2-silver
ADMIN_UTILS_VERSION=0.0.1-SNAPSHOT-gold

# Bootstrap swarm
echo "@@@@@@@@@ Bootstrap swarm"
ansible-playbook -i $INVENTORY_PATH ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm --extra-vars=@config --extra-vars=@advanced

# Deploy API Manager
echo "@@@@@@@@@ Deploy API Manager"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-api-manager" --extra-vars "hub_org=${ORG} echo_server_image_name=echo-server echo_server_image_tag=${ECHO_SERVER_VERSION}" --extra-vars=@config --extra-vars=@advanced

# Deploy Admin Utils API
echo "@@@@@@@@@ Deploy Admin Utils API"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-adminutil" --extra-vars "hub_org=${ORG} image_name=adminutil image_tag=${ADMIN_UTILS_VERSION}" --extra-vars=@config --extra-vars=@advanced

# Onboard APIs
echo "@@@@@@@@@ Onboard APIs"
ansible-playbook -i $INVENTORY_PATH ../ansible/api-manager.yml --tags kong-api  --extra-vars=@config --extra-vars=@advanced

# Onboard Consumers
echo "@@@@@@@@@ Onboard Consumers"
ansible-playbook -v -i $INVENTORY_PATH ../ansible/api-manager.yml --tags kong-consumer --extra-vars=@config --extra-vars=@advanced
