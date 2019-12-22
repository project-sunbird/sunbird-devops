# vim: set ts=4 sw=4 tw=0 et :

#!/bin/bash
set -eu -o pipefail

## vars Updater{{{
function vars_updater {
    sed -i "s/\b10.1.4.4\b/${core_ip}/g" ../ansible/inventory/env/{hosts,common.yml}
    sed -i "s/\b10.1.4.5\b/${dbs_ip}/g" ../ansible/inventory/env/{hosts,common.yml}
    sed -i "s/\b10.1.4.6\b/${kp_ip}/g" ../ansible/inventory/env/{hosts,common.yml}
    sed -i "s/\bansible_ssh_user=ops\b/ansible_ssh_user=${ssh_user}/g" ../ansible/inventory/env/hosts
    sed -i "s/\bsunbird.centralindia.cloudapp.azure.com\b/${domain_name}/g" ../ansible/inventory/env/common.yml
    sed -i "/\bcore_vault_proxy_site_key\b/c\core_vault_proxy_site_key: \"{{ lookup('file', \'${nginx_key_path}\') }}\"" ../ansible/inventory/env/secrets.yml
    sed -i "/\bcore_vault_proxy_site_crt\b/c\core_vault_proxy_site_crt: \"{{ lookup('file', \'${nginx_cert_path}\') }}\"" ../ansible/inventory/env/secrets.yml
    sed -i "/\bcore_vault_sunbird_sso_publickey\b:/c\core_vault_sunbird_sso_publickey: \'${sso_publickey}\'" ../ansible/inventory/env/secrets.yml
    sed -i "/\bcore_vault_sunbird_keycloak_user_federation_provider_id\b:/c\core_vault_sunbird_keycloak_user_federation_provider_id: \'${keycloak_user_federation_provider_id}\'" ../ansible/inventory/env/secrets.yml
    sed -i "/\bcore_vault_sunbird_azure_storage_key\b:/c\core_vault_sunbird_azure_storage_key: \'${azure_storage_key}\'" ../ansible/inventory/env/secrets.yml
    sed -i "/\blp_vault_azure_storage_secret\b:/c\lp_vault_azure_storage_secret: \'${azure_storage_key}\'" ../ansible/inventory/env/secrets.yml
    sed -i "/\bazure_account_name\b:/c\azure_account_name: \'${storage_account_name}\'" ../ansible/inventory/env/common.yml
    sed -i "/\bazure_public_container\b:/c\azure_public_container: \'${storage_container_name}\'" ../ansible/inventory/env/common.yml
    sed -i "/\bsunbird_content_azure_storage_container\b:/c\sunbird_content_azure_storage_container: \'${storage_container_name}\'" ../ansible/inventory/env/common.yml
}
#}}}

# Importing user defined variables
source 3node.vars
mkdir -p ~/.config/sunbird
# Installing deps
bash install-deps.sh
export ANSIBLE_HOST_KEY_CHECKING=false

# installing dbs
# Installing all dbs
echo $inventory_path
#########################
#
#       CORE
#
#########################
module=Core
version=2.6.0

echo "downloading artifacts"
artifacts="keycloak_artifacts.zip cassandra_artifacts.zip"
ansible_path=${HOME}/sunbird-devops/ansible
for artifact in $artifacts;
do
    wget -N https://sunbirdpublic.blob.core.windows.net/installation/$version/$module/$artifact -P $ansible_path
done

# installing unzip
sudo apt install unzip
ansible_path=${HOME}/sunbird-devops/ansible
unzip -o $ansible_path/cassandra_artifacts.zip -d $ansible_path

# Creating inventory strucure
git checkout -- ../ansible/inventory/env/group_vars/all.yml # This is to make sure always the all.yaml is updated
cp $inventory_path/$module/* ../ansible/inventory/env/
# Updating variables and ips
vars_updater

# Install db only once
if [[ ! -f ~/.config/sunbird/db ]]; then
# Installing dbs (es, cassandra, postgres)
ansible-playbook -i ../ansible/inventory/env ../ansible/provision.yml --skip-tags "postgresql-slave,log-es"
ansible-playbook -i ../ansible/inventory/env ../ansible/postgresql-data-update.yml
ansible-playbook -i ../ansible/inventory/env ../ansible/es-mapping.yml --extra-vars "indices_name=all ansible_tag=run_all_index_and_mapping"
ansible-playbook -i ../ansible/inventory/env ../ansible/cassandra-deploy.yml -e "cassandra_jar_path=$ansible_path cassandra_deploy_path=/home/{{ansible_ssh_user}}" -v
touch ~/.config/sunbird/db
fi


# Bootstrapping kubernetes
ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/bootstrap_minimal.yaml
services=" apimanager learner nginx-private-ingress"
for service in $services;
do
  echo "@@@@@@@@@@@@@@ Deploying $service @@@@@@@@@@@@@@@@@@"
  ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/${service} release_name=${service} role_name=sunbird-deploy" -v
done

# Provisioning keycloak
ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags provision
ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags deploy -e "artifact_path=keycloak_artifacts.zip deploy_monit=false"
ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags bootstrap -v

# Have to refactor with some kind of function args
echo "
open another shell and run
ssh -L 12000:localhost:8080 ops@${core_ip}
open browser and goto localhost:12000
username: admin
password: admin
"
exit 0

# Installing API manager
ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/deploy_core_service.yml -e chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/apimanager -e "release_name=apimanager role_name=sunbird-deploy kong_admin_api_url=http://$(hostname -i):12000/admin-api" -v

# echo "@@@@@@@@@ Onboard APIs"
ansible-playbook -i ../ansible/inventory/env ../ansible/api-manager.yml -e kong_admin_api_url=http://$(hostname -i):12000/admin-api --tags kong-api

# echo "@@@@@@@@@ Onboard Consumers"
## This will generate a player token in /root/jwt_token_player.txt
echo "@@@@@@@@@ Onboard Consumers"
ansible-playbook -i ../ansible/inventory/env ../ansible/api-manager.yml -e "kong_admin_api_url=http://$(hostname -i):12000/admin-api kubeconfig_path=/etc/rancher/k3s/k3s.yaml" --tags kong-consumer

jwt_token=$(sudo cat /root/jwt_token_player.txt|xargs)
# services="adminutil apimanager badger cert content enc learner lms notification player telemetry userorg"
services="adminutils knowledgemw lms apimanager content learner player telemetry nginx-public-ingress"
for service in $services;
do
  echo "@@@@@@@@@@@@@@ Deploying $service @@@@@@@@@@@@@@@@@@"
  ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/ops/sunbird-devops/kubernetes/helm_charts/core/${service} release_name=${service} role_name=sunbird-deploy sunbird_api_auth_token=${jwt_token}" -v
done
kubectl rollout restart deployment -n dev

#########################
#
#       KP
#
#########################
# Installing KP
module=KnowledgePlatform
source 3node.vars
# Checking out specific revision of KP
[[ -d ~/sunbird-learning-platform ]] || git clone https://github.com/project-sunbird/sunbird-learning-platform -b release-$version ~/sunbird-learning-platform && cd ~/sunbird-learning-platform; git pull origin release-$version; cd -

# Creating inventory strucure
cp $inventory_path/$module/* ../ansible/inventory/env/
cp ~/sunbird-learning-platform/ansible/inventory/env/group_vars/all.yml ../ansible/inventory/env/group_vars/
ansible_path=${HOME}/sunbird-learning-platform
vars_updater

echo "downloading artifacts"
artifacts="lp_artifacts.zip lp_neo4j_artifacts.zip lp_cassandratrigger_artifacts.zip"

for artifact in $artifacts;
do
    wget -N https://sunbirdpublic.blob.core.windows.net/installation/$version/$module/$artifact -P $ansible_path/ansible/
done
# installing unzip
cd $ansible_path
find ./ -type f -iname "*.zip" -exec unzip -o {} \;
cd -
# Downloading neo4j
wget -N https://sunbirdpublic.blob.core.windows.net/installation/neo4j-community-3.3.9-unix.tar.gz -P $ansible_path/ansible/artifacts/
cp $ansible_path/ansible/cassandra.transaction-event-handler-*.jar $ansible_path/static-files

ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_learning_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_search_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/cassandra-trigger-deploy.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_cassandra_db_update.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_zookeeper_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_kafka_provision.yml
# Will create all topic
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_kafka_setup.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_learning_neo4j_provision.yml -e "download_neo4j=false neo4j_zip=neo4j-community-3.3.9-unix.tar.gz neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_redis_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_learning_neo4j_deploy.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_start_neo4j.yml -e "neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/es_composite_search_cluster_setup.yml -v
bash ./csindexupdate.sh
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_learning_deploy.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_search_deploy.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_definition_update.yml -e "neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"
