#!/bin/sh
# Build script
# set -o errexit

ENV=staging
ORG=sunbird
KEYCLOAK_VERSION=3.2.1.Final-bronze

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"

# Create application network
echo "@@@@@@@@@ Keycloak deploy"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags "stack-keycloak1" --extra-vars "deploy_keycloak1=true hub_org=${ORG} image_name=keycloak_image image_tag=$KEYCLOAK_VERSION service_name=keycloak1"
