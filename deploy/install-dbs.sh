#!/bin/sh
# Build script
# set -o errexit

ENV=staging

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"

#Elasticsearch installation
echo "@@@@@@@@@ Elasticsearch installation"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/provision.yml --tags es

# Cassandra installation
echo "@@@@@@@@@ Cassandra installation"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags cassandra

# Postgresql-master installation
echo "@@@@@@@@@ Postgresql-master installation"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/deploy.yml --tags  provision_postgres
