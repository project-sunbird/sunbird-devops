#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1
ignore_folder=.sunbird/ignore

if [ -f $ignore_folder/es ];then
#Elasticsearch installation
echo "@@@@@@@@@ Elasticsearch installation"
ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --tags es --extra-vars=@config 
fi

if [ -f $ignore_folder/cassandra ];then
# Cassandra installation
echo "@@@@@@@@@ Cassandra installation"
ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --tags cassandra --extra-vars=@config 
fi

if [ -f $ignore_folder/postgres ];then
# Postgresql-master installation
echo "@@@@@@@@@ Postgresql-master installation"
ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --tags  postgresql-master --extra-vars=@config 
fi
