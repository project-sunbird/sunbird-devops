#!/bin/bash
set -e -o pipefail

# Deleting the container if it's already running


sleep 10 

if [ "$#" -ne 1 ]; then
    echo "ERROR: Illegal number of parameters"
    echo "Usage: $0 <inventory-path>"
    exit 1
fi

inventory_path="deploy/$1"
ansible_mount_dir=$(readlink -f ../)

# Creating container to onboard apis and consumers

echo "@@@@@@@@ Creating ansible service"

# Creating ansible service
if [[ ! $(sudo docker service ls | grep ansible_container ) ]];then
sudo docker service create --name ansible_container --mount source=$ansible_mount_dir,target=/ansible,type=bind,readonly --network api-manager_default sunbird/ansible:latest
fi

# Waiting for service to start
sleep 5

# Getting container id
ansible_container=$(sudo docker ps | grep sunbird/ansible | awk '{print $1}')

# Onboard APIs
echo "@@@@@@@@@ Onboard APIs"
sudo docker exec $ansible_container ansible-playbook -i $inventory_path ansible/api-manager.yml --tags kong-api  --extra-vars=@deploy/config --connection local

# Onboard Consumers
echo "@@@@@@@@@ Onboard Consumers"
sudo docker exec $ansible_container ansible-playbook -v -i $inventory_path ansible/api-manager.yml --tags kong-consumer --extra-vars=@deploy/config --connection local

# Removing service as it's not needed anymore
sudo docker service rm ansible_container
sleep 5
sudo docker rmi -f sunbird/ansible:latest
sudo docker image prune -f
