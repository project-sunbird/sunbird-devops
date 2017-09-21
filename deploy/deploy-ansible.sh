#!/bin/sh
# Build script
# set -o errexit

# Create application network
echo "Bootstrap swarm"
ansible-playbook -i ../ansible/inventory/staging ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm

# Re-deploy Actor service
#echo "Redeploy actor service"
#ensure_service_is_killed actor-service
#docker service create -p 8088:8088 --name actor-service --hostname actor-service --reserve-memory $ACTOR_SERVICE_RESERVED_MEMORY --limit-memory $ACTOR_SERVICE_MEMORY_LIMIT --network $APPLICATION_NETWORK --env-file ./configs/sunbird_actor-service.env sunbird/actor-service:$ACTOR_SERVICE_VERSION
#
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
