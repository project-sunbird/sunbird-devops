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

# Saving kong api url
kong_admin_api_url=$(docker service ps api-manager_kong | grep Runn | head -n1 | awk '{print $4}')

# Bootstrap swarm
echo "@@@@@@@@@ Bootstrap swarm"
ansible-playbook -i $INVENTORY_PATH ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm

# Deploy API Manager
echo "@@@@@@@@@ Deploy API Manager"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-api-manager" --extra-vars "hub_org=${ORG} echo_server_image_name=echo-server echo_server_image_tag=${ECHO_SERVER_VERSION}"

# Deploy Admin Utils API
echo "@@@@@@@@@ Deploy Admin Utils API"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-adminutil" --extra-vars "hub_org=${ORG} image_name=adminutil image_tag=${ADMIN_UTILS_VERSION}"

# Onboard APIs
echo "@@@@@@@@@ Onboard APIs"
ansible-playbook -i $INVENTORY_PATH ../ansible/api-manager.yml --tags kong-api --extra-vars kong_admin_api_url=http://$kong_admin_api_url:8001

# Onboard Consumers
echo "@@@@@@@@@ Onboard Consumers"
ansible-playbook -v -i $INVENTORY_PATH ../ansible/api-manager.yml --tags kong-consumer --extra-vars kong_admin_api_url=http://$kong_admin_api_url:8001
