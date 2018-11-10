#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

ORG=sunbird
# Getting versions
source version.env

# Bootstrap swarm
echo "@@@@@@@@@ Bootstrap swarm"
ansible-playbook -i $INVENTORY_PATH ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm --extra-vars=@config.yml

# Re-deploy Proxy
echo "Redeploy Proxy"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-proxy" --extra-vars "hub_org=${ORG} image_name=proxy image_tag=${PROXY_VERSION}" --extra-vars=@config.yml
