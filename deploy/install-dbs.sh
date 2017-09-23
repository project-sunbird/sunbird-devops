#!/bin/sh
# Build script
# set -o errexit

ANSIBLE_VERSION=2.4.0.0-1ppa~xenial
# Install Ansible
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible=$ANSIBLE_VERSION

ENV=staging

mkdir -p ../ansible/secrets
touch "../ansible/secrets/$ENV.yml"

#Elasticsearch installation
echo "@@@@@@@@@ Elasticsearch installation"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/provision.yml --tags es

# Cassandra installation
echo "@@@@@@@@@ Cassandra installation"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/provision.yml --tags cassandra

# Postgresql-master installation
echo "@@@@@@@@@ Postgresql-master installation"
ansible-playbook -i ../ansible/inventory/$ENV ../ansible/provision.yml --tags  provision_postgres
