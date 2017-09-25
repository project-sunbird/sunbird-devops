#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1
ENV=$(basename "$INVENTORY_PATH")

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"

ORG=sunbird
PROXY_VERSION=0.0.1-gold

# Bootstrap swarm
echo "@@@@@@@@@ Bootstrap swarm"
ansible-playbook -i $INVENTORY_PATH ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm

# Re-deploy Proxy
echo "Redeploy Proxy"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-proxy" --extra-vars "hub_org=${ORG} image_name=proxy image_tag=${PROXY_VERSION}"
