#!/bin/sh
# Build script
# set -o errexit

APPLICATION_NETWORK=application

ACTOR_SERVICE_RESERVED_MEMORY=768M
ACTOR_SERVICE_MEMORY_LIMIT=1024M
ACTOR_SERVICE_VERSION=0.0.1-gold

PLAYER_RESERVED_MEMORY=64M
PLAYER_MEMORY_LIMIT=256M
PLAYER_VERSION=0.0.6-gold

CONTENT_SERVICE_RESERVED_MEMORY=64M
CONTENT_SERVICE_MEMORY_LIMIT=256M
CONTENT_SERVICE_VERSION=0.0.1-gold

LEARNER_SERVICE_RESERVED_MEMORY=256M
LEARNER_SERVICE_MEMORY_LIMIT=512M
LEARNER_SERVICE_VERSION=0.0.1-gold

ensure_application_network_exists () {
  if test "$(docker network ls | grep $APPLICATION_NETWORK | wc -l)" = 0
  then
    echo "Creating application network"
    docker network create --attachable --driver overlay $APPLICATION_NETWORK
  else
    echo "Application network already exists"
  fi
  echo "done"
}

ensure_service_is_killed () {
  echo "Kill service $1"

  if test "$(docker service ls | grep $1 | wc -l)" = 0
  then
    echo "Service $1 does not exist"
  else
    echo "Killing $1"
    docker service rm $1
  fi
}

# Create application network
echo "Ensure app network"
ensure_application_network_exists

# Re-deploy Actor service
echo "Redeploy actor service"
ensure_service_is_killed actor-service
docker service create -p 8088:8088 --name actor-service --hostname actor-service --reserve-memory $ACTOR_SERVICE_RESERVED_MEMORY --limit-memory $ACTOR_SERVICE_MEMORY_LIMIT --network $APPLICATION_NETWORK --env-file ./configs/sunbird_actor-service.env sunbird/actor-service:$ACTOR_SERVICE_VERSION

# Re-deploy Player service
echo "Redeploy player service"
ensure_service_is_killed player
docker service create -p 3000:3000 --name player --reserve-memory $PLAYER_RESERVED_MEMORY --limit-memory $PLAYER_MEMORY_LIMIT --network $APPLICATION_NETWORK --env-file ./configs/sunbird_player.env sunbird/player:$PLAYER_VERSION

# Re-deploy Content service
echo "Redeploy content service"
ensure_service_is_killed content_service
docker service create -p 5000:5000 --name content_service --reserve-memory $CONTENT_SERVICE_RESERVED_MEMORY --limit-memory $CONTENT_SERVICE_MEMORY_LIMIT --network $APPLICATION_NETWORK --env-file ./configs/sunbird_content_service.env sunbird/content_service:$CONTENT_SERVICE_VERSION

# Re-deploy Learner service
echo "Redeploy learner service"
ensure_service_is_killed learner_service
docker service create -p 9000:9000 --name learner_service --reserve-memory $LEARNER_SERVICE_RESERVED_MEMORY --limit-memory $LEARNER_SERVICE_MEMORY_LIMIT --network $APPLICATION_NETWORK --env-file ./configs/sunbird_learner_service.env sunbird/learner_service:$LEARNER_SERVICE_VERSION
