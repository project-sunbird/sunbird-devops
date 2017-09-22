#!/bin/sh
# Build script
# set -o errexit

ENV=staging

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"


# Cassandra installation
echo "@@@@@@@@@ Cassandra installation"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/cassandra-data.yml

# Postgresql installation
echo "@@@@@@@@@ Cassandra installation"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/postgresql-data-update.yml