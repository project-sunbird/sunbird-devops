#!/bin/sh
# Build script
# set -o errexit

ENV=staging
ORG=sunbird
ACTOR_SERVICE_VERSION=0.0.1-gold

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"

# Create application network
echo "Bootstrap swarm"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm

# Re-deploy Actor service
echo "Redeploy actor service"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=actor-service image_tag=$ACTOR_SERVICE_VERSION service_name=actor-service deploy_actor=True"


## Re-deploy Player service
#echo "Redeploy player service"
#ensure_service_is_killed player
#docker service create -p 3000:3000 --name player --reserve-memory $PLAYER_RESERVED_MEMORY --limit-memory $PLAYER_MEMORY_LIMIT --network $APPLICATION_NETWORK --env-file ./configs/sunbird_player.env sunbird/player:$PLAYER_VERSION
#
## Re-deploy Content service
#echo "Redeploy content service"
#ensure_service_is_killed content_service
#docker service create -p 5000:5000 --name content_service --reserve-memory $CONTENT_SERVICE_RESERVED_MEMORY --limit-memory $CONTENT_SERVICE_MEMORY_LIMIT --network $APPLICATION_NETWORK --env-file ./configs/sunbird_content_service.env sunbird/content_service:$CONTENT_SERVICE_VERSION
#
## Re-deploy Learner service
#echo "Redeploy learner service"
#ensure_service_is_killed learner_service
#docker service create -p 9000:9000 --name learner_service --reserve-memory $LEARNER_SERVICE_RESERVED_MEMORY --limit-memory $LEARNER_SERVICE_MEMORY_LIMIT --network $APPLICATION_NETWORK --env-file ./configs/sunbird_learner_service.env sunbird/learner_service:$LEARNER_SERVICE_VERSION
