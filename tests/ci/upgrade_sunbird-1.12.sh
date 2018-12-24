#!/bin/bash

backupdbs(){
cd /home/$username/sunbird-devops/deploy
scp -i $ansible_private_key_path -o StrictHostKeyChecking=no $backup_script $release_file $config_file $username@$database_host:/tmp
ssh -i $ansible_private_key_path -o StrictHostKeyChecking=no $username@$database_host "bash /tmp/backup_dbs-$version.sh $release $username"
}

updateSSO(){
   access_token=$(curl -s -X POST http://$dns_name/auth/realms/master/protocol/openid-connect/token -H "cache-control: no-cache" -H "content-type: application/x-www-form-urlencoded" -d "client_id=admin-cli&username=admin&password=$keycloak_pass&grant_type=password" | jq -r ".access_token")
   public_key=$(curl -s -X GET http://$dns_name/auth/admin/realms/sunbird/keys -H "Authorization: Bearer $access_token" -H "Cache-Control: no-cache" -H "Content-Type: application/json" | jq -r ".keys[0].publicKey")
   sed -i "s|sunbird_sso_publickey:.*#|sunbird_sso_publickey: $public_key                    #|g" $config_file
}

upgradeSB(){
./sunbird_install.sh -s config
if [[ $? -ne 0 ]]; then
   echo -e "Config file generation failed.." | tee $upgrade_log
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

verifyUpgrade(){
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

copyLogs(){
   mkdir logs 2> /dev/null
   cp $upgrade_log logs
   scp -i $ansible_private_key_path -o StrictHostKeyChecking=no $username@$database_host:/tmp/backuplog.txt logs
}


postResult(){
   copyLogs
   echo "release: $previous to $release" >> $build_info
   echo "status: Failed" >> $build_info
   echo "subject: $previous build succeeded, upgrade to $release failed" >> $build_info
   exit 1
}

config_file=$1
release=$2
build_info=$3
version=$4
previous=$5
username=$(awk '/ssh_ansible_user:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
ansible_private_key_path=$(awk '/ansible_private_key_path:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
dns_name=$(awk '/dns_name:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
database_host=$(awk '/database_host:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
keycloak_pass=$(awk '/keycloak_admin_password:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
sso_pass=$(awk '/sso_password:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
backup_script=/tmp/tests/ci/backup_dbs-$version.sh
upgrade_log=/tmp/upgradelog.txt

backupdbs
if [[ $? -eq 0 ]]; then
   updateSSO
   upgradeSB
   verifyUpgrade
else
   echo -e "Database backup failed. Skipping upgrade.." | tee -a $upgrade_log
   postResult
fi

if [[ $flag -eq 1 ]]; then
   echo "Found mismatch in container versions.." | tee -a $upgrade_log
   postResult
else
   copyLogs
   echo "Sunbird upgrade successful" | tee -a $upgrade_log
   echo "release: $previous to $release" >> $build_info
   echo "status: Success" >> $build_info
   echo "subject: $previous build succeeded, upgrade to $release succeeded" >> $build_info
fi
