#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

ENV=sample
ORG=sunbird
# Getting image versions
source version.env
[ -f ~/jwt_token_player.txt ] || echo "JWT token (~/jwt_token_player.txt) not found" || exit 1
sunbird_api_auth_token=$(cat ~/jwt_token_player.txt|sed 's/ //g')

# Re-deploy Player service
echo "@@@@@@@@@ Redeploy player service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=player image_tag=${PLAYER_VERSION} service_name=player deploy_stack=True sunbird_api_auth_token=${sunbird_api_auth_token} vault_badging_authorization_key=${badger_token}" --extra-vars @config.yml

# Re-deploy Learner service
echo "Redeploy learner service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=learner_service image_tag=${LEARNER_SERVICE_VERSION} service_name=learner-service deploy_learner=True  sunbird_api_auth_token=${sunbird_api_auth_token} vault_badging_authorization_key=${badger_token}" --extra-vars @config.yml -v

# Re-deploy Content service
echo "Redeploy content service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=content-service image_tag=${CONTENT_SERVICE_VERSION} service_name=content-service deploy_content=True sunbird_api_auth_token=${sunbird_api_auth_token} vault_badging_authorization_key=${badger_token}" --extra-vars @config.yml

#Telemetry-Service
echo "Redeploy Telemetry service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=telemetry-service image_tag=${TELEMETRY_SERVICE_VERSION} service_name=telemetry-service deploy_telemetry=True" --extra-vars @config.yml

