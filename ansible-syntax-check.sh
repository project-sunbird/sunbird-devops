#!/bin/sh

SCRIPT_BASE_DIR=$(dirname $0)
SUNBIRD_DEVOPS_FOLDER=$SCRIPT_BASE_DIR

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory>"
    echo "Example: $0 $SUNBIRD_DEVOPS_FOLDER/ansible/inventories/sample"
    exit 1
fi

set -e

INVENTORY_DIR=$1

for playbook_yaml in $SUNBIRD_DEVOPS_FOLDER/ansible/*.yml; do
  ansible-playbook -i $INVENTORY_DIR $playbook_yaml --syntax-check -e "hosts=dummy"
done