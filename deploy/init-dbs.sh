#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

INVENTORY_PATH=$1
ENV=$(basename "$INVENTORY_PATH")

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"

# Cassandra installation
echo "@@@@@@@@@ Cassandra data"
ansible-playbook -i $INVENTORY_PATH ../ansible/cassandra-data.yml

# Postgresql installation
echo "@@@@@@@@@ Postgresql data"
ansible-playbook -i $INVENTORY_PATH ../ansible/postgresql-data-update.yml