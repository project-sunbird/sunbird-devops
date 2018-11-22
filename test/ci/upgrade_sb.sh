#!/bin/bash

backupdbs(){
scp -i $ansible_private_key_path -o StrictHostKeyChecking=no $backup_script $release_file $config_file $username@$database_host:/tmp
ssh -i $ansible_private_key_path -o StrictHostKeyChecking=no $username@$database_host "bash /tmp/backup_dbs.sh"
}

checkoutRepo(){
cd /home/$username
sudo rm -rf sunbird-devops
git clone https://github.com/project-sunbird/sunbird-devops.git
cd sunbird-devops
IFS="/" read -r var1 var2 <<< $release
if [[ $var1 == "tags" ]]; then
   git checkout $release -b $var2
   echo -e "Instlling sunbird $var2"
else
   git checkout -b $var1 origin/$var1
   echo -e "Installing sunbird $var1"
fi
cd deploy
}

copyConfig(){
   if [[ -f config ]]; then
      cp $config_file config
      config_file=config
   else
      cp $config_file config.yml
      config_file=config.yml
   fi
}

updateSSO(){
   access_token=$(curl -s -X POST http://$dns_name/auth/realms/master/protocol/openid-connect/token -H "cache-control: no-cache" -H "content-type: application/x-www-form-urlencoded" -d "client_id=admin-cli&username=admin&password=$keycloak_pass&grant_type=password" | jq -r ".access_token")
   public_key=$(curl -s -X GET http://$dns_name/auth/admin/realms/sunbird/keys -H "Authorization: Bearer $access_token" -H "Cache-Control: no-cache" -H "Content-Type: application/json" | jq -r ".keys[0].publicKey")
   sed -i "s|sunbird_sso_publickey:.*#|sunbird_sso_publickey: $public_key                    #|g" $config_file
}

upgradeSB(){
./sunbird_install.sh -s config
if [[ $? -ne 0 ]]; then
   echo -e "Config file generation failed.." | tee -a $upgrade_log
   postResult
fi

./sunbird_install.sh -s dbs
if [[ $? -ne 0 ]]; then
   echo -e "DB migration failed.." | tee -a $upgrade_log
   postResult
fi

./sunbird_install.sh -s apis
if [[ $? -ne 0 ]]; then
   echo -e "API service upgrade failed.." | tee -a $upgrade_log
   postResult
fi

./sunbird_install.sh -s proxy
if [[ $? -ne 0 ]]; then
   echo -e "Proxy service upgrade failed.." | tee -a $upgrade_log
   postResult
fi

./sunbird_install.sh -s core
if [[ $? -ne 0 ]]; then
   echo -e "Core services upgrade failed.." | tee -a $upgrade_log
   postResult
fi
}

checkUpgrade(){
flag=0
declare -a services=("badger" "content" "kong" "learner" "player" "proxy" "telemetry")
for i in ${services[@]}
do
docker_version=$(sudo docker service ls | awk '/'$i'/{print $5}' | awk -F ":" '{print $2}')
release_version=$(awk -F "=" 'tolower($0) ~ /'$i'/ {print $2}' version.env)

if [[ $docker_version == $release_version ]]; then
   echo -e "\e[0;32m$i service upgraded successfully to $docker_version\e[0;37m" | tee -a $upgrade_log
else
   echo -e "\e[0;31m$i service could not be upgraded. Release version is $release_version, but docker version is $docker_version. Please investigate..\e[0;37m" | tee -a $upgrade_log
   flag=1
fi
done
}

archiveLogs(){
   sudo apt install -y zip
   cp $upgrade_log logs
   scp -i $ansible_private_key_path -o StrictHostKeyChecking=no $username@$database_host:/tmp/backup_log.txt logs
   zip -r /tmp/serverlogs.zip logs
}

sendEmail(){
   python /tmp/send_email.py
}

postResult(){
   echo "failed" >> /tmp/release_to_build
   echo "Upgrade to release $release failed" >> /tmp/release_to_build
   archiveLogs
   sendEmail
   exit 1
}

config_file=/tmp/config.yml.sample
release_file=/tmp/release_to_build
release=$(cat /tmp/release_to_build | head -1)
username=$(awk '/ssh_ansible_user:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
ansible_private_key_path=$(awk '/ansible_private_key_path:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
dns_name=$(awk '/dns_name:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
database_host=$(awk '/database_host:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
keycloak_pass=$(awk '/keycloak_admin_password:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
sso_pass=$(awk '/sso_password:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
backup_script=/tmp/backup_dbs.sh
upgrade_log=/tmp/upgrade_log.txt

checkoutRepo
backupdbs
if [[ $? -eq 0 ]]; then
   copyConfig
   updateSSO
   upgradeSB
   checkUpgrade
else
   echo -e "Database backup failed. Skipping upgrade.." | tee -a $upgrade_log
   postResult
fi

if [[ $flag -eq 1 ]]; then
   echo "Found mismatch in container versions.." | tee -a $upgrade_log
   postResult
else
   echo "success" >> /tmp/release_to_build
   echo "Upgrade to release $release succeeded" >> /tmp/release_to_build
   archiveLogs
   sendEmail
fi
