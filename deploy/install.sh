#!/bin/bash

# Installing deps
# sudo ./install-deps.sh

# installing dbs
# Installing all dbs
echo $INVENTORY_PATH
[[ $INVENTORY_PATH == "" ]] && echo -e "ERROR: set environment variable \nexport INVENTORY_PATH=/path/to/ansible/inventory" && exit 100
module=Core
# Creating inventory strucure
cp $INVENTORY_PATH/$module/* ../ansible/inventory/env/
# Installing dbs (es, cassandra, postgres)
# ansible-playbook -i ../ansible/inventory/env/ ../ansible/provision.yml --skip-tags "postgresql-slave,log-es"

# Bootstrapping k8s
ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/bootstrap_minimal.yaml
# Installing API manager and onboarding apis
ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/apimanager -e release_name=apimanager
