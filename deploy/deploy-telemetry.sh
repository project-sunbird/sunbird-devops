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


echo "Redeploy telemetry service"
ansible-playbook -i $INVENTORY_PATH ../ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${ORG} image_name=telemetry-service image_tag=${TELEMETRY_SERVICE_VERSION} service_name=telemetry-service deploy_telemetry=True" --extra-vars @config.yml

