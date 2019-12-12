# vim: set ts=4 sw=4 tw=0 et :
#!/bin/bash
set -eu -o pipefail

# Installing deps
bash install-deps.sh

# installing dbs
# Installing all dbs
echo $INVENTORY_PATH
[[ $INVENTORY_PATH == "" ]] && echo -e "ERROR: set environment variable \nexport INVENTORY_PATH=/path/to/ansible/inventory" && exit 100
module=Core
version=2.6.0
# Creating inventory strucure
cp $INVENTORY_PATH/$module/* ../ansible/inventory/env/
# Installing dbs (es, cassandra, postgres)
ansible-playbook -i ../ansible/inventory/env/ ../ansible/provision.yml --skip-tags "postgresql-slave,log-es"
ansible-playbook -i ../ansible/inventory/env/ ../ansible/postgresql-data-update.yml
#
# Bootstrapping k8s
ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/bootstrap_minimal.yaml
# Installing API manager
ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/apimanager -e release_name=apimanager -v

# Onboard apis
echo "@@@@@@@@@ Onboard APIs"
ansible-playbook -i ../ansible/inventory/env/ ../ansible/api-manager.yml --tags kong-api

# Onboard Consumers
## This will generate a player token in /root/jwt_token_player.txt
echo "@@@@@@@@@ Onboard Consumers"
ansible-playbook -v -i ../ansible/inventory/env/ ../ansible/api-manager.yml --tags kong-consumer

jwt_token=$(sudo cat /root/jwt_token_player.txt)
#

# services="adminutil apimanager badger cert content enc learner lms notification player telemetry userorg"
# disabling some services due to unavailability of public images
services="adminutil apimanager content learner player telemetry nginx-private-ingress nginx-public-ingress"
for service in $services;
do
  echo "@@@@@@@@@@@@@@ Deploying $service @@@@@@@@@@@@@@@@@@"
  ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/${service} release_name=${service} sunbird_api_auth_token=${jwt_token}"
done
# Provisioning keycloak
ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags provision
# Deploying keycloak
ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags deploy -e "artifact_path=${HOME}/keycloak_artifacts.zip"
# Bootstrapping keycloak
ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags bootstrap -v


# Installing KP
module=KnowledgePlatform
# Checking out specific revision of KP
# git clone https://github.com/project-sunbird/sunbird-learning-platform -b release-$version ~/

# Creating inventory strucure
cp $INVENTORY_PATH/$module/* ../ansible/inventory/env/
cp ~/sunbird-learning-platform/ansible/inventory/env/group_vars/all.yml ../ansible/inventory/env/group_vars/
ansible_path=${HOME}/sunbird-learning-platform

echo "downloading artifacts"
artifacts="lp_artifacts.zip lp_neo4j_artifacts.zip"

for artifact in $artifacts;
do
    wget -N https://sunbirdpublic.blob.core.windows.net/installation/$version/$module/$artifact -P $ansible_path/ansible/
done
# installing unzip
sudo apt install unzip
cd $ansible_path/ansible
find ./ -type f -iname "*.zip" -exec unzip -o {} \;
cd -
# Downloading neo4j
wget -N https://sunbirdpublic.blob.core.windows.net/installation/neo4j-community-3.3.9-unix.tar.gz -P $ansible_path/ansible/artifacts/

ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_zookeeper_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_kafka_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_kafka_setup.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_neo4j_provision.yml -e "download_neo4j=false neo4j_zip=neo4j-community-3.3.9-unix.tar.gz neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_neo4j_deploy.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_start_neo4j.yml -e "neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_definition_update.yml -e "neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_redis_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/ansible/lp_learning_deploy.yml
