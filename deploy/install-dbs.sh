#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

#Elasticsearch installation
echo "@@@@@@@@@ Elasticsearch installation"
ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --tags es

# Cassandra installation
echo "@@@@@@@@@ Cassandra installation"
ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --tags cassandra

# Postgresql-master installation
echo "@@@@@@@@@ Postgresql-master installation"
ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --tags  postgresql-master

# Mongodb installation
echo "@@@@@@@@@ Mongodb installation"
ansible-playbook -i $INVENTORY_PATH ../ansible/provision.yml --tags "mongodb"
