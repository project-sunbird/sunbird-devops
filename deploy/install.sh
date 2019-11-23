#!/bin/bash
set -eu -o pipefail

# Installing deps
bash install-deps.sh

# installing dbs
# Installing all dbs
echo $INVENTORY_PATH
[[ $INVENTORY_PATH == "" ]] && echo -e "ERROR: set environment variable \nexport INVENTORY_PATH=/path/to/ansible/inventory" && exit 100
module=Core
# Creating inventory strucure
cp $INVENTORY_PATH/$module/* ../ansible/inventory/env/
# Installing dbs (es, cassandra, postgres)
ansible-playbook -i ../ansible/inventory/env/ ../ansible/provision.yml --tags postgresql-master #--skip-tags "postgresql-slave,log-es"
ansible-playbook -i ../ansible/inventory/env/ ../ansible/postgresql-data-update.yml #--skip-tags "postgresql-slave,log-es"

# # Bootstrapping k8s
ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/bootstrap_minimal.yaml
# # Installing API manager
ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/apimanager -e release_name=apimanager -v

Onboaring apis
echo "@@@@@@@@@ Onboard APIs"
ansible-playbook -i ../ansible/inventory/env/ ../ansible/api-manager.yml --tags kong-api

# Onboard Consumers
## This will generate a player token in /root/jwt_token_player.txt
echo "@@@@@@@@@ Onboard Consumers"
ansible-playbook -v -i ../ansible/inventory/env/ ../ansible/api-manager.yml --tags kong-consumer

jwt_token=$(sudo cat /root/jwt_token_player.txt)

services="adminutil apimanager badger cert content enc learner lms notification player telemetry userorg"
for service in $services;
do
  ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/${service} release_name=${service} core_vault_kong__test_jwt=${jwt_token}"
done
