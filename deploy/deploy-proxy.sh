#!/bin/sh
# Build script
# set -o errexit

ENV=staging
ORG=sunbird
PROXY_VERSION=0.0.1-gold

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"

# Bootstrap swarm
echo "@@@@@@@@@ Bootstrap swarm"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm

# Re-deploy Proxy
echo "Redeploy Proxy"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags "stack-proxy" --extra-vars "hub_org=${ORG} image_name=proxy image_tag=${PROXY_VERSION}"
