#!/usr/bin/env bash
# Provision servers
set -eu -o pipefail
set -x

source deployments/deployment/env.sh
az login
az account set --subscription "${AZURE_SUBSCRIPTION}"
az group create \
    --name $AZURE_RG_NAME \
    --location $AZURE_RG_LOCATION
az group deployment create \
    --name $AZURE_DEPLOYMENT_NAME \
    --mode "Incremental" \
    --resource-group $AZURE_RG_NAME \
    --template-file "./deployments/deployment/azuredeploy.json" \
    --parameters "@./deployments/deployment/azuredeploy.parameters.json" \
    --verbose 
az logout
exit