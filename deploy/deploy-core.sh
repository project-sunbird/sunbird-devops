#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

ENV=sample
ORG=sunbird
ACTOR_SERVICE_VERSION=1.5.0-gold
PLAYER_VERSION=1.5.0-gold
CONTENT_SERVICE_VERSION=1.5.0-gold
LEARNER_SERVICE_VERSION=1.5.0-gold
PROXY_VERSION=1.5.0-gold
BADGER_SERVICE_VERSION=1.5.0-gold

# Bootstrap swarm
echo "@@@@@@@@@ Bootstrap swarm"
ansible-playbook -i $INVENTORY_PATH ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm --extra-vars @config 

# Re-deploy Player service
echo "@@@@@@@@@ Redeploy player service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=player image_tag=${PLAYER_VERSION} service_name=player deploy_stack=True" --extra-vars @config 

# Re-deploy Content service
echo "Redeploy content service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=content_service image_tag=${CONTENT_SERVICE_VERSION} service_name=content_service deploy_stack=True" --extra-vars @config 

# Re-deploy Learner service
echo "Redeploy learner service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=learner_service image_tag=${LEARNER_SERVICE_VERSION} service_name=learner-service deploy_learner=True" --extra-vars @config 

# Re-deploy Actor service
echo "@@@@@@@@@ Redeploy actor service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=actor-service image_tag=$ACTOR_SERVICE_VERSION service_name=actor-service deploy_actor=True" --extra-vars @config 
