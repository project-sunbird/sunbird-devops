#!/usr/bin/env bash
# Provision servers
set -eu -o pipefail
set -x

source deployments/deployment/app/env.sh
AZURE_APP_DEPLOYMENT_NAME="$AZURE_DEPLOYMENT_NAME-app"
AZURE_DB_DEPLOYMENT_NAME="$AZURE_DEPLOYMENT_NAME-db"
az login
az account set --subscription "${AZURE_SUBSCRIPTION}"
az group create \
    --name $AZURE_RG_NAME \
    --location $AZURE_RG_LOCATION
az group deployment create \
    --name $AZURE_APP_DEPLOYMENT_NAME \
    --mode "Incremental" \
    --resource-group $AZURE_RG_NAME \
    --template-file "./deployments/deployment/app/azuredeploy.json" \
    --parameters "@./deployments/deployment/app/azuredeploy.parameters.json" \
    --verbose 
if [ -e ./deployments/deployment/db/azuredeploy.parameters.json ]; then
    az group deployment create \
        --name $AZURE_DB_DEPLOYMENT_NAME \
        --mode "Incremental" \
        --resource-group $AZURE_RG_NAME \
        --template-file "./deployments/deployment/db/azuredeploy.json" \
        --parameters "@./deployments/deployment/db/azuredeploy.parameters.json" \
        --verbose 
else
    echo -e "DB Setup skipped"
fi
# az vm create \
#     --resource-group $AZURE_RG_NAME \
#     --name DB-1 \
#     --image UbuntuLTS \
#     --public-ip-address ""
#     --ssh-key-value 
#     --vnet-name MyVnet 
#     --subnet subnet1
az logout
exit