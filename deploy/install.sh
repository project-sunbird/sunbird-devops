# vim: set ts=4 sw=4 tw=0 et :
#!/bin/bash
set -eu -o pipefail

# # Installing deps
# bash install-deps.sh
# 
# # installing dbs
# # Installing all dbs
# echo $INVENTORY_PATH
# [[ $INVENTORY_PATH == "" ]] && echo -e "ERROR: set environment variable \nexport INVENTORY_PATH=/path/to/ansible/inventory" && exit 100
# module=Core
# version=2.6.0
# # Creating inventory strucure
# cp $INVENTORY_PATH/$module/* ../ansible/inventory/env/
# # Installing dbs (es, cassandra, postgres)
# ansible-playbook -i ../ansible/inventory/env/ ../ansible/provision.yml --skip-tags "postgresql-slave,log-es"
# ansible-playbook -i ../ansible/inventory/env/ ../ansible/postgresql-data-update.yml
# #
# # Bootstrapping k8s
# ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/bootstrap_minimal.yaml
# # Installing API manager
# ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/apimanager -e release_name=apimanager -v
# 
# # Onboard apis
# echo "@@@@@@@@@ Onboard APIs"
# ansible-playbook -i ../ansible/inventory/env/ ../ansible/api-manager.yml --tags kong-api
# 
# # Onboard Consumers
# ## This will generate a player token in /root/jwt_token_player.txt
# echo "@@@@@@@@@ Onboard Consumers"
# ansible-playbook -v -i ../ansible/inventory/env/ ../ansible/api-manager.yml --tags kong-consumer
# 
# jwt_token=$(sudo cat /root/jwt_token_player.txt)
# #
# 
# # services="adminutil apimanager badger cert content enc learner lms notification player telemetry userorg"
# # disabling some services due to unavailability of public images
# services="adminutil apimanager content learner player telemetry nginx-private-ingress nginx-public-ingress"
# for service in $services;
# do
#   echo "@@@@@@@@@@@@@@ Deploying $service @@@@@@@@@@@@@@@@@@"
#   ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/${service} release_name=${service} sunbird_api_auth_token=${jwt_token}"
# done
# # Provisioning keycloak
# ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags provision
# # Deploying keycloak
# ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags deploy -e "artifact_path=${HOME}/keycloak_artifacts.zip"
# # Bootstrapping keycloak
# ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags bootstrap -v


# Installing KP
module=KnowledgePlatform
# Creating inventory strucure
cp $INVENTORY_PATH/$module/* ../ansible/inventory/env/
ansible_path=${HOME}/sunbird-learning-platform
# Checking out specific revision of KP
git clone https://github.com/project-sunbird/sunbird-learning-platform -b release-$version ~/

echo "downloading artifacts"
artifacts="lp_artifacts.zip lp_neo4j_artifacts.zip"
# installing unzip
for artifact in $artifacts;
do
    wget https://sunbirdpublic.blob.core.windows.net/installation/$version/$module/$artifact -P $ansible_path/
done

# Installing neo4j
# This version installs neo4j enterprize edition which will have validity for 1 month
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_kafka_provision.yml -e download_neo4j=false
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_kafka_setup.yml -e download_neo4j=false
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_neo4j_provision.yml -e download_neo4j=false
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_redis_provision.yml -e download_neo4j=false
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_provision.yml -e "zip_file="
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_deploy.yml -e "zip_file="
