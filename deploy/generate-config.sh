#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <implementation-name> <environment-name> <type>"
    echo  -e "\nOPTIONS\n"
    echo "type: core, azure"
    echo "implementation-name: Name of the implementation organization or the project using sunbird eg: ntp, nile"
    echo "environment-name: Name of the environment for which config should be generated. eg: dev, staging, production"
    exit 1
fi

set -e

IMPLEMENTATION_NAME=$1
ENVIRONMENT_NAME=$2
CONFIG_TYPE=$3

IMPLEMENTATION_DEVOPS_DIR="$IMPLEMENTATION_NAME-devops"

SCRIPT_BASE_DIR=$(dirname $0)
echo "SCRIPT_BASE_DIR" $SCRIPT_BASE_DIR
SUNBIRD_DEVOPS_FOLDER=$SCRIPT_BASE_DIR/.. # TODO: This should be derived from script base path
echo "SUNBIRD_DEVOPS_FOLDER" $SUNBIRD_DEVOPS_FOLDER
SAMPLE_ENVIRONMENT_NAME=sample

BACKUP_SUFFIX=-`date +"%Y-%m-%d-%H-%M-%S"`.bak

if [ $3 == "core" ]; then
    echo -e "Creating core service/db configuration files...\n"
    sleep 1
    SAMPLE_INVENTORY_FILE=$SUNBIRD_DEVOPS_FOLDER/ansible/inventories/sample/hosts
    SAMPLE_GROUP_VARS_DIR=$SUNBIRD_DEVOPS_FOLDER/ansible/inventories/sample/group_vars
    SAMPLE_GROUP_VARS_FILE=$SAMPLE_GROUP_VARS_DIR/sample

    ENVIRONMENT_INVENTORY_DIR=$IMPLEMENTATION_DEVOPS_DIR/ansible/inventories/$ENVIRONMENT_NAME
    ENVIRONMENT_GROUP_VARS_DIR=$ENVIRONMENT_INVENTORY_DIR/group_vars

    ENVIRONMENT_INVENTORY_HOSTS_FILE=$ENVIRONMENT_INVENTORY_DIR/hosts
    ENVIRONMENT_GROUP_VARS_FILE=$ENVIRONMENT_GROUP_VARS_DIR/$ENVIRONMENT_NAME

    ENVIRONMENT_SECRET_FILE=$ENVIRONMENT_INVENTORY_DIR/secrets.yml

    # Create inventory
    mkdir -p $ENVIRONMENT_INVENTORY_DIR
    cp --backup --suffix $BACKUP_SUFFIX $SAMPLE_INVENTORY_FILE $ENVIRONMENT_INVENTORY_HOSTS_FILE
    sed -i -e s/"$SAMPLE_ENVIRONMENT_NAME"/"$ENVIRONMENT_NAME"/g $ENVIRONMENT_INVENTORY_HOSTS_FILE

    # Create group_vars
    mkdir -p $ENVIRONMENT_GROUP_VARS_DIR
    cp --backup --suffix $BACKUP_SUFFIX $SAMPLE_GROUP_VARS_FILE $ENVIRONMENT_GROUP_VARS_FILE
    sed -i -e s/"$SAMPLE_ENVIRONMENT_NAME"/"$ENVIRONMENT_NAME"/g $ENVIRONMENT_GROUP_VARS_FILE
    ## Additional group_vars
    cp --backup --suffix $BACKUP_SUFFIX $SAMPLE_GROUP_VARS_DIR/postgresql-master $ENVIRONMENT_GROUP_VARS_DIR/postgresql-master

    # Create secrets
    if [ ! -e "$ENVIRONMENT_SECRET_FILE" ]; then
    touch "$ENVIRONMENT_SECRET_FILE"
    fi

    echo "Successfully generated $IMPLEMENTATION_DEVOPS_DIR directory with environment $ENVIRONMENT_NAME"
    echo "Please review & edit files $ENVIRONMENT_INVENTORY_HOSTS_FILE and $ENVIRONMENT_GROUP_VARS_FILE"
    echo "You can remove backup files by running find $IMPLEMENTATION_DEVOPS_DIR -name *.bak -type f -delete"
elif [ $3 == "azure" ]; then
    echo "Creating azure cloud configuration files..."
    sleep 1
    APP_DEPLOY_PARAMS_DIR=$IMPLEMENTATION_DEVOPS_DIR/$ENVIRONMENT_NAME/azure/app
    SAMPLE_APP_DEPLOY_PARAMS_DIR=$SUNBIRD_DEVOPS_FOLDER/cloud/azure/arm/swarm/acs-engine
    SAMPLE_DEPLOY_PARAMS_COMMON_FILE=$SAMPLE_APP_DEPLOY_PARAMS_DIR/common/azuredeploy.json
    SAMPLE_DEPLOY_PARAMS_JSON_FILE=$SAMPLE_APP_DEPLOY_PARAMS_DIR/production.sample/azuredeploy.parameters.json.sample
    SAMPLE_DEPLOY_ENV_FILE=$SAMPLE_APP_DEPLOY_PARAMS_DIR/production.sample/env.sh

    mkdir -p $APP_DEPLOY_PARAMS_DIR
    echo "Created $APP_DEPLOY_PARAMS_DIR"
    cp $SAMPLE_DEPLOY_PARAMS_COMMON_FILE $APP_DEPLOY_PARAMS_DIR/azuredeploy.json
    cp $SAMPLE_DEPLOY_PARAMS_JSON_FILE $APP_DEPLOY_PARAMS_DIR/azuredeploy.parameters.json
    cp $SAMPLE_DEPLOY_ENV_FILE $APP_DEPLOY_PARAMS_DIR/env.sh
    sed -i -e s/"$SAMPLE_ENVIRONMENT_NAME"/"$ENVIRONMENT_NAME"/g $APP_DEPLOY_PARAMS_DIR/azuredeploy.parameters.json
    sed -i -e s/"$SAMPLE_ENVIRONMENT_NAME"/"$ENVIRONMENT_NAME"/g $APP_DEPLOY_PARAMS_DIR/env.sh
    echo "Copied Azure ARM template and params for Application"
    echo "Please update azuredeploy.parameters.json and env.sh"

    echo "Creating DB VM configuration files..."

    DB_DEPLOY_PARAMS_DIR=$IMPLEMENTATION_DEVOPS_DIR/$ENVIRONMENT_NAME/azure/db
    SAMPLE_DB_DEPLOY_PARAMS_DIR=$SUNBIRD_DEVOPS_FOLDER/cloud/azure/arm/vm
    SAMPLE_DEPLOY_PARAMS_COMMON_FILE=$SAMPLE_DB_DEPLOY_PARAMS_DIR/azuredeploy.json
    SAMPLE_DEPLOY_PARAMS_JSON_FILE=$SAMPLE_DB_DEPLOY_PARAMS_DIR/azuredeploy.parameters.json.sample

    mkdir -p $DB_DEPLOY_PARAMS_DIR
    echo "Created $DB_DEPLOY_PARAMS_DIR"
    cp $SAMPLE_DEPLOY_PARAMS_COMMON_FILE $DB_DEPLOY_PARAMS_DIR/azuredeploy.json
    cp $SAMPLE_DEPLOY_PARAMS_JSON_FILE $DB_DEPLOY_PARAMS_DIR/azuredeploy.parameters.json
    sed -i -e s/"$SAMPLE_ENVIRONMENT_NAME"/"$ENVIRONMENT_NAME"/g $DB_DEPLOY_PARAMS_DIR/azuredeploy.parameters.json
    echo "Copied Azure ARM template and params for DB"
    echo "Please update azuredeploy.parameters.json"
else
    echo "invalid option"
fi
unset APP_DEPLOYMENT_JSON_PATH
unset DB_DEPLOYMENT_JSON_PATH
