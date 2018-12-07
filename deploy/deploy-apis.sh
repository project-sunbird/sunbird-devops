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


# Bootstrap swarm
echo "@@@@@@@@@ Bootstrap swarm"
ansible-playbook -i $INVENTORY_PATH ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm --extra-vars=@config.yml

# Deploy API Manager
echo "@@@@@@@@@ Deploy API Manager"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-api-manager" --extra-vars "hub_org=${ORG} echo_server_image_name=echo-server echo_server_image_tag=${ECHO_SERVER_VERSION} kong_version=${KONG_VERSION}" --extra-vars=@config.yml

sleep 20

# Deploy Admin Utils API
echo "@@@@@@@@@ Deploy Admin Utils API"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-adminutil" --extra-vars "hub_org=${ORG} image_name=adminutil image_tag=${ADMIN_UTILS_VERSION}" --extra-vars=@config.yml

sleep 10

# Saving kong api url
kong_admin_api_url=$(sudo docker service ps api-manager_kong | grep Runn | head -n1 | awk '{print $4}')
echo $kong_admin_api_url
retry_count=5
while [[ $kong_admin_api_url = '' && retry_count -ge 0 ]]; do
    kong_admin_api_url=$(sudo docker service ps api-manager_kong | grep Runn | head -n1 | awk '{print $4}')
    echo "api-manager kong container is not running, waiting for 5 more seconds, retying $retry_count"
    sleep 5
    ((retry_count--))
    if [[ $kong_admin_api_url = '' ]] && [[ retry_count -eq 0 ]];then 
        echo "api manger kong is not running, exiting script"
        exit 1
    fi
done

# Onboard APIs
echo "@@@@@@@@@ Onboard APIs"
ansible-playbook -i $INVENTORY_PATH ../ansible/api-manager.yml --tags kong-api --extra-vars kong_admin_api_url=http://$kong_admin_api_url:8001 --extra-vars=@config.yml

# Onboard Consumers
echo "@@@@@@@@@ Onboard Consumers"
ansible-playbook -v -i $INVENTORY_PATH ../ansible/api-manager.yml --tags kong-consumer --extra-vars kong_admin_api_url=http://$kong_admin_api_url:8001 --extra-vars=@config.yml
