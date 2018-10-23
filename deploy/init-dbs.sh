#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1

# Cassandra installation
echo "@@@@@@@@@ Cassandra data"
ansible-playbook -i $INVENTORY_PATH ../ansible/cassandra-data.yml --extra-vars=@config.yml

# Postgresql installation
echo "@@@@@@@@@ Postgresql data"
ansible-playbook -i $INVENTORY_PATH ../ansible/postgresql-data-update.yml --extra-vars=@config.yml

# Elasticsearch installation
echo "@@@@@@@@@ Postgresql data"
ansible-playbook -i $INVENTORY_PATH ../ansible/curl_commands.yml --extra-vars=@config.yml 


