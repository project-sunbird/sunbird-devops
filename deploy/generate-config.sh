#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <implementation-name> <environment-name>"
    echo "\nOPTIONS\n"
    echo "implementation-name Name of the implementation organization or the project using sunbird eg: ntp, nile"
    echo "environment-name  Name of the environment for which config should be generated. eg: dev, staging, production"
    exit 1
fi

set -e

IMPLEMENTATION_NAME=$1
ENVIRONMENT_NAME=$2

IMPLEMENTATION_DEVOPS_DIR="$IMPLEMENTATION_NAME-devops"

SCRIPT_BASE_DIR=$(dirname $0)
SUNBIRD_DEVOPS_FOLDER=$SCRIPT_BASE_DIR/.. # TODO: This should be derived from script base path
SAMPLE_INVENTORY_FILE=$SUNBIRD_DEVOPS_FOLDER/ansible/inventory/sample
SAMPLE_GROUP_VARS_FILE=$SUNBIRD_DEVOPS_FOLDER/ansible/group_vars/sample
SAMPLE_ENVIRONMENT_NAME=sample

ENVIRONMENT_INVENTORY_DIR=$IMPLEMENTATION_DEVOPS_DIR/ansible/inventories/$ENVIRONMENT_NAME
ENVIRONMENT_GROUP_VARS_DIR=$ENVIRONMENT_INVENTORY_DIR/group_vars

ENVIRONMENT_INVENTORY_HOSTS_FILE=$ENVIRONMENT_INVENTORY_DIR/hosts
ENVIRONMENT_GROUP_VARS_FILE=$ENVIRONMENT_GROUP_VARS_DIR/$ENVIRONMENT_NAME

mkdir -p $ENVIRONMENT_INVENTORY_DIR
cp $SAMPLE_INVENTORY_FILE $ENVIRONMENT_INVENTORY_HOSTS_FILE
sed -i -e s/"$SAMPLE_ENVIRONMENT_NAME"/"$ENVIRONMENT_NAME"/g $ENVIRONMENT_INVENTORY_HOSTS_FILE

mkdir -p $ENVIRONMENT_GROUP_VARS_DIR
cp $SAMPLE_GROUP_VARS_FILE $ENVIRONMENT_GROUP_VARS_FILE
sed -i -e s/"$SAMPLE_ENVIRONMENT_NAME"/"$ENVIRONMENT_NAME"/g $ENVIRONMENT_GROUP_VARS_FILE

echo "Successfully generated $IMPLEMENTATION_DEVOPS_DIR directory with environment $ENVIRONMENT_NAME"
echo "Please review & edit files $ENVIRONMENT_INVENTORY_HOSTS_FILE and $ENVIRONMENT_GROUP_VARS_FILE"
