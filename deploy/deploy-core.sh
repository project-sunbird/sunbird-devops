#!/bin/sh
# Build script
# set -o errexit

ENV=staging
ORG=sunbird
ACTOR_SERVICE_VERSION=0.0.1-gold
PLAYER_VERSION=0.0.7-gold
CONTENT_SERVICE_VERSION=0.0.1-gold
LEARNER_SERVICE_VERSION=0.0.1-gold

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"

# Create application network
echo "@@@@@@@@@ Bootstrap swarm"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/bootstrap.yml  --extra-vars "hosts=swarm-manager" --tags bootstrap_swarm

# Re-deploy Actor service
echo "@@@@@@@@@ Redeploy actor service"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=actor-service image_tag=$ACTOR_SERVICE_VERSION service_name=actor-service deploy_actor=True"

# Re-deploy Player service
echo "@@@@@@@@@ Redeploy player service"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=player image_tag=${PLAYER_VERSION} service_name=player deploy_stack=True"

# Re-deploy Content service
echo "Redeploy content service"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=content_service image_tag=${CONTENT_SERVICE_VERSION} service_name=content_service deploy_stack=True"

# Re-deploy Learner service
echo "Redeploy learner service"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=learner_service image_tag=${LEARNER_SERVICE_VERSION} service_name=learner-service deploy_learner=True"
