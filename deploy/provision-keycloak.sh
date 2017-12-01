#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

ANSIBLE_VERSION=2.4.1.0-1ppa~xenial
# Install Ansible
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible=$ANSIBLE_VERSION

INVENTORY_PATH=$1

#Keycloak installation
echo "@@@@@@@@@ Keycloak "
ansible-playbook -i $INVENTORY_PATH ../ansible/keycloak.yml --tags provision