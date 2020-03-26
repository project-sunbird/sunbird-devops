# vim: set ts=4 sw=4 tw=0 et :

#!/bin/bash
set -eu -o pipefail

# This is to fix cross terminal compatibility
export LC_ALL=C
export ANSIBLE_FORCE_COLOR=true

# Make sure there are no keys in ssh-agent
eval $(ssh-agent -s)

# Color schemes
BOLD="$(tput bold)"
GREEN="${BOLD}$(tput setaf 2)"
YELLOW="${BOLD}$(tput setaf 3)"
WHITE="$(tput sgr0)${BOLD}"
NORMAL="$(tput sgr0)"

## vars Updater{{{
function vars_updater {
    # These are the placeholder values till keyclaok provision
    sso_publickey=${sso_publickey:-"this-variable-will-be-replaced-after-keycloak-installation"}
    keycloak_user_federation_provider_id=${keycloak_user_federation_provider_id:-"this-variable-will-be-replaced-after-keycloak-installation"}
    sed -i "s/\b10.1.4.4\b/${core_ip}/g" ../ansible/inventory/env/{hosts,common.yml}
    sed -i "s/\b10.1.4.5\b/${dbs_ip}/g" ../ansible/inventory/env/{hosts,common.yml}
    sed -i "s/\b10.1.4.6\b/${kp_ip}/g" ../ansible/inventory/env/{hosts,common.yml}
    sed -i "s/\bansible_ssh_user=ops\b/ansible_ssh_user=${ssh_user}/g" ../ansible/inventory/env/hosts
    sed -i "s#\bansible_ssh_private_key_file=/home/ops/deployer.pem\b#ansible_ssh_private_key_file=/home/${ssh_user}/deployer.pem#g" ../ansible/inventory/env/hosts
    sed -i "s/\bsunbird.centralindia.cloudapp.azure.com\b/${domain_name}/g" ../ansible/inventory/env/common.yml
    sed -i "/\bcore_vault_proxy_site_key\b/c\core_vault_proxy_site_key: \"{{ lookup('file', \'${nginx_key_path}\') }}\"" ../ansible/inventory/env/secrets.yml
    sed -i "/\bcore_vault_proxy_site_crt\b/c\core_vault_proxy_site_crt: \"{{ lookup('file', \'${nginx_cert_path}\') }}\"" ../ansible/inventory/env/secrets.yml
    sed -i "/\bcore_vault_sunbird_azure_storage_key\b:/c\core_vault_sunbird_azure_storage_key: \'${azure_storage_key}\'" ../ansible/inventory/env/secrets.yml
    sed -i "/\blp_vault_azure_storage_secret\b:/c\lp_vault_azure_storage_secret: \'${azure_storage_key}\'" ../ansible/inventory/env/secrets.yml
    sed -i "/\bazure_account_name\b:/c\azure_account_name: \'${storage_account_name}\'" ../ansible/inventory/env/common.yml
    sed -i "/\bazure_public_container\b:/c\azure_public_container: \'${storage_container_name}\'" ../ansible/inventory/env/common.yml
    sed -i "/\bsunbird_content_azure_storage_container\b:/c\sunbird_content_azure_storage_container: \'${storage_container_name}\'" ../ansible/inventory/env/common.yml
    # This variable will only be set after keycloak provision
    sed -i "/\bcore_vault_sunbird_sso_publickey\b:/c\core_vault_sunbird_sso_publickey: \'${sso_publickey}\'" ../ansible/inventory/env/secrets.yml
    sed -i "/\bcore_vault_sunbird_keycloak_user_federation_provider_id\b:/c\core_vault_sunbird_keycloak_user_federation_provider_id: \'${keycloak_user_federation_provider_id}\'" ../ansible/inventory/env/secrets.yml
}
#}}}

# Importing user defined variables
source 3node.vars
echo set 0400 for keyfile
[[ -f ~/deployer.pem ]] && chmod 0400 ~/deployer.pem || ( echo "coudn't find ~/deployer.pem. Installation is aborting"; exit 100 )
mkdir -p ~/.config/sunbird
# Creating ssl

[[ -f ~/.config/sunbird/certbot ]] || ( [[ $create_ssl == 'true' ]] && (echo ${GREEN}Creating SSL certificate.${NORMAL}; bash certbot.sh; touch ~/.config/sunbird/certbot ))

cat <<EOF


${WHITE}Starting sunbird installation. It'll take almost 1hr to complete. 

${YELLOW}You can wait or leave the insallation behind, if you're running on ${WHITE}tmux${YELLOW}

It's good to run the installation on tmux, because network will fail, all the time.
If something goes wrong, don't worry. ${WHITE} rerun the script ${YELLOW} most times, it'll figure out what to do.

To run the installation in tmux, if not already, follow the instructions
1. cancel the script : ${WHITE}ctrl+c${YELLOW}
2. start tmux: ${WHITE}tmux${YELLOW}
3. start installation: ${WHITE}cd ~/sunbird-devops/deploy && bash -x install.sh${YELLOW}

This script will wait for 20 seconds for user to cancel
${NORMAL}
EOF
# commenting the below one and can be uncomment later
#sleep 20

# Installing deps
bash install-deps.sh
export ANSIBLE_HOST_KEY_CHECKING=false

# installing dbs
echo $inventory_path
#########################
#
#       CORE
#
#########################
module=Core

echo "downloading artifacts"
artifacts="cassandra_artifacts.zip v3.zip content-plugins.zip formdata.zip keycloak_artifacts.zip"
ansible_path=${HOME}/sunbird-devops/ansible
for artifact in $artifacts;
do
    wget -N https://sunbirdpublic.blob.core.windows.net/installation/$version/$module/$artifact -P $ansible_path
done

# installing unzip
sudo apt install unzip
find $ansible_path -maxdepth 1 -type f ! -name "keycloak_artifacts.zip" -iname "*.zip" -exec unzip -o {} -d $ansible_path \;

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

source version.env
# Bootstrapping kubernetes
ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/bootstrap_minimal.yaml


echo "@@@@@@@@@@@@@@ Deploying apimanager @@@@@@@@@@@@@@@@@@" 
ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/${ssh_user}/sunbird-devops/kubernetes/helm_charts/core/apimanager image_tag=${apimanager} release_name=apimanager role_name=sunbird-deploy" -vvvv
rm -rf /home/deployer/sunbird-devops/kubernetes/ansible/roles/sunbird-deploy/templates/*

echo "@@@@@@@@@@@@@@ Deploying nginx-private-ingress @@@@@@@@@@@@@@@@@@"
ansible-playbook -i ../ansible/inventory/env/ ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/${ssh_user}/sunbird-devops/kubernetes/helm_charts/core/nginx-private-ingress release_name=nginx-private-ingress role_name=helm-deploy" -v


# Provisioning keycloak
if [[ ! -f ~/.config/sunbird/keycloak ]]; then
    ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml --tags provision
    ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml -e keycloak_bootstrap_url=http://${core_ip}:8080/auth --tags deploy -e "artifact_path=keycloak_artifacts.zip deploy_monit=false"
    ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml -e keycloak_bootstrap_url=http://${core_ip}:8080/auth --tags bootstrap -v
    # Hack to install clients
    ansible-playbook -i ../ansible/inventory/env ../ansible/keycloak.yml -e keycloak_bootstrap_url=http://${core_ip}:8080/auth --tags deploy -e "artifact_path=keycloak_artifacts.zip deploy_monit=false"
    touch ~/.config/sunbird/keycloak
fi

# generating sso token and storage provider for keycloak
access_token=$(curl -s -X POST http://localhost:8080/auth/realms/master/protocol/openid-connect/token -H "cache-control: no-cache" -H "content-type: application/x-www-form-urlencoded" -d "client_id=admin-cli&username=admin&password=admin&grant_type=password" | jq -r ".access_token")
sso_publickey=$(curl -s -X GET http://localhost:8080/auth/admin/realms/sunbird/keys -H "Authorization: Bearer $access_token" -H "Cache-Control: no-cache" -H "Content-Type: application/json" | jq -r ".keys[0].publicKey")

if [[ ! -f ~/.config/sunbird/keycloak_cassandra_storage_provider ]]; then
# Creating cassandra-storage-provider
curl -s -X POST "http://localhost:8080/auth/admin/realms/sunbird/components" -H 'Accept: application/json' --compressed -H 'Content-Type: application/json;charset=utf-8' -H "Authorization: Bearer $access_token" --data '{"name":"cassandra-storage-provider","providerId":"cassandra-storage-provider","providerType":"org.keycloak.storage.UserStorageProvider","parentId":"sunbird","config":{"priority":["0"],"cachePolicy":["DEFAULT"],"evictionDay":[],"evictionHour":[],"evictionMinute":[],"maxLifespan":[],"host":["localhost"]}}'
touch ~/.config/sunbird/keycloak_cassandra_storage_provider
fi

# Getting cassandra_storage_federation provider
keycloak_user_federation_provider_id=$(curl -sS "http://localhost:8080/auth/admin/realms/sunbird/components/" -H 'Accept: application/json, text/plain, */*' --compressed -H "Authorization: Bearer $access_token" | jq -r 'to_entries[] | [.value.id, .value.name] | @tsv' | grep cassandra-storage-provider | awk '{print $1}' | xargs)
# Updating variables
vars_updater


# Installing API manager
ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/deploy_core_service.yml -e chart_path=/home/${ssh_user}/sunbird-devops/kubernetes/helm_charts/core/apimanager -e "release_name=apimanager role_name=sunbird-deploy image_tag=${apimanager} kong_admin_api_url=http://$(hostname -i):12000/admin-api" -v
rm -rf /home/deployer/sunbird-devops/kubernetes/ansible/roles/sunbird-deploy/templates/*

echo "@@@@@@@@@ Onboard APIs"
ansible-playbook -i ../ansible/inventory/env ../ansible/api-manager.yml -e kong_admin_api_url=http://$(hostname -i):12000/admin-api --tags kong-api

echo "@@@@@@@@@ Onboard Consumers"
## This will generate a player token in /root/jwt_token_player.txt
echo "@@@@@@@@@ Onboard Consumers"
ansible-playbook -i ../ansible/inventory/env ../ansible/api-manager.yml -e "kong_admin_api_url=http://$(hostname -i):12000/admin-api kubeconfig_path=/etc/rancher/k3s/k3s.yaml" --tags kong-consumer -v | tee -a ~/consumers.logs

jwt_token=$(sudo cat /root/jwt_token_player.txt|xargs)
# Deploying the adminutils
echo "@@@@@@@@@@@@@@ Deploying adminutils @@@@@@@@@@@@@@@@@@"
ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/${ssh_user}/sunbird-devops/kubernetes/helm_charts/core/adminutils release_name=adminutils image_tag=${adminutils} role_name=helm-deploy sunbird_api_auth_token=${jwt_token}" -v

services="knowledgemw lms content learner telemetry"
for service in $services;
do
  echo "@@@@@@@@@@@@@@ Deploying $service @@@@@@@@@@@@@@@@@@"
  ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/${ssh_user}/sunbird-devops/kubernetes/helm_charts/core/${service} release_name=${service} image_tag=${!service} role_name=sunbird-deploy sunbird_api_auth_token=${jwt_token}" -vvvv
rm -rf /home/deployer/sunbird-devops/kubernetes/ansible/roles/sunbird-deploy/templates/*
done

echo "@@@@@@@@@@@@@@ Deploying player @@@@@@@@@@@@@@@@@@"
ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/${ssh_user}/sunbird-devops/kubernetes/helm_charts/core/player release_name=player image_tag=${player} role_name=deploy-player sunbird_api_auth_token=${jwt_token}" -vvvv
rm -rf /home/deployer/sunbird-devops/kubernetes/ansible/roles/sunbird-deploy/templates/*

echo "@@@@@@@@@@@@@@ Deploying nginx-public-ingress @@@@@@@@@@@@@@@@@@"
ansible-playbook -i ../ansible/inventory/env ../kubernetes/ansible/deploy_core_service.yml -e "kubeconfig_path=/etc/rancher/k3s/k3s.yaml chart_path=/home/${ssh_user}/sunbird-devops/kubernetes/helm_charts/core/nginx-public-ingress release_name=nginx-public-ingress role_name=helm-deploy image_tag="" " -v

kubectl rollout restart deployment -n dev

# Uploding content-plugins
ansible-playbook -i ../ansible/inventory/env ../ansible/deploy-plugins.yml -e"folder_name=content-plugins source_name=${ansible_path}/content-plugins" --tags core-plugins
ansible-playbook -i ../ansible/inventory/env ../ansible/deploy-plugins.yml -e"folder_name=v3/preview source_name=${ansible_path}/v3" --tags core-plugins

#########################
#
#       KP
#
#########################
# Installing KP
module=KnowledgePlatform
source 3node.vars
# Checking out specific revision of KP
[[ -d ~/sunbird-learning-platform ]] || git clone https://github.com/project-sunbird/sunbird-learning-platform -b release-$version ~/sunbird-learning-platform && cd ~/sunbird-learning-platform; git config rebase.autoStash true; git pull --rebase origin release-$version; cd -

# Creating inventory strucure
cp $inventory_path/$module/* ../ansible/inventory/env/
cp ~/sunbird-learning-platform/ansible/inventory/env/group_vars/all.yml ../ansible/inventory/env/group_vars/
ansible_path=${HOME}/sunbird-learning-platform/ansible
vars_updater

echo "downloading artifacts"
artifacts="lp_artifacts.zip lp_neo4j_artifacts.zip lp_cassandratrigger_artifacts.zip"

for artifact in $artifacts;
do
    wget -N https://sunbirdpublic.blob.core.windows.net/installation/$version/$module/$artifact -P $ansible_path
done
# installing unzip
cd $ansible_path
find ./ -maxdepth 1 -type f -iname "*.zip" -exec unzip -o {} \;
cd -
# Downloading neo4j
wget -N https://sunbirdpublic.blob.core.windows.net/installation/neo4j-community-3.3.9-unix.tar.gz -P $ansible_path/artifacts/
cp $ansible_path/cassandra.transaction-event-handler-*.jar $ansible_path/static-files

ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_learning_provision.yml --extra-vars offline_kp=true
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_search_provision.yml
if [[ ! -f ~/.config/sunbird/lp_db ]]; then
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/cassandra-trigger-deploy.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_cassandra_db_update.yml
touch ~/.config/sunbird/lp_db
fi
# Will create all topic
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_learning_neo4j_provision.yml -e "download_neo4j=false neo4j_zip=neo4j-community-3.3.9-unix.tar.gz neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_start_neo4j.yml -e "neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_redis_provision.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_learning_neo4j_deploy.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/es_composite_search_cluster_setup.yml -v
bash ./csindexupdate.sh ${kp_ip}
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_learning_deploy.yml --extra-vars offline_kp=true
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_search_deploy.yml
ansible-playbook -i ../ansible/inventory/env ${ansible_path}/lp_definition_update.yml -e "neo4j_home={{learner_user_home}}/{{neo4j_dir}}/neo4j-community-3.3.9"

# patching cassanda migration
# This is a workaround for cassandra migration issues
ansible_path=${HOME}/sunbird-devops/ansible
# Creating inventory strucure
git checkout -- ../ansible/inventory/env/group_vars/all.yml # This is to make sure always the all.yaml is updated
cp $inventory_path/$module/* ../ansible/inventory/env/
# Updating variables and ips
vars_updater
ansible-playbook -i ../ansible/inventory/env ../ansible/cassandra-deploy.yml -e "cassandra_jar_path=$ansible_path cassandra_deploy_path=/home/{{ansible_ssh_user}}" -v

# Post installation
bash apis.sh
# Creating form data
wget -N https://raw.githubusercontent.com/project-sunbird/sunbird-devops/master/deploy/cassandra_restore.py
scp -r -i ~/deployer.pem ../ansible/cassandra_backup cassandra_restore.py ${dbs_ip}:~/
ssh -i ~/deployer.pem -n ${dbs_ip} python cassandra_restore.py --snapshotdir cassandra_backup --host ${dbs_ip}

bash postinstall.sh
