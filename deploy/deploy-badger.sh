#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

inventory_path="$1"                                                                                                                                       
org="sunbird" 
# Importing versions
source version.env

#Deploy Badger             
echo "@@@@@@@@@ Badger "  
ansible-playbook -i $inventory_path ../ansible/deploy-badger.yml  --extra-vars=@config.yml --extra-vars "hub_org=${org} image_name=badger image_tag=${BADGER_SERVICE_VERSION}"
