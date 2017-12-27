#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

ANSIBLE_VERSION=2.4*
# Install Ansible
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible=$ANSIBLE_VERSION

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
