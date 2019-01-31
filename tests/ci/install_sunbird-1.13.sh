#!/bin/bash

installSunbird(){
   echo -e "Starting installation..." | tee $installer_log
   bash sunbird_install.sh
}

updateSSO(){
   access_token=$(curl -s -X POST http://$dns_name/auth/realms/master/protocol/openid-connect/token -H "cache-control: no-cache" -H "content-type: application/x-www-form-urlencoded" -d "client_id=admin-cli&username=admin&password=$keycloak_pass&grant_type=password" | jq -r ".access_token")
   public_key=$(curl -s -X GET http://$dns_name/auth/admin/realms/sunbird/keys -H "Authorization: Bearer $access_token" -H "Cache-Control: no-cache" -H "Content-Type: application/json" | jq -r ".keys[0].publicKey")
   sed -i "s|sunbird_sso_publickey:.*#|sunbird_sso_publickey: $public_key                    #|g" $config_file
}

coreInstall(){
   echo -e "Sunbird installation complete - Starting core installation..." | tee -a $installer_log
   bash sunbird_install.sh -s core
}

systemInit(){
    bash sunbird_install.sh -s systeminit
}

postTest(){
    bash sunbird_install.sh -s posttest
}

copyLogs(){
   mkdir logs 2> /dev/null
   cp $installer_log logs
}

postResult(){
   copyLogs
   echo "status: Failed" >> $build_info
   echo "subject: $release build failed" >> $build_info
   exit 1
}

config_file=$1
release=$2
build_info=$3
dns_name=$(awk '/dns_name:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
keycloak_pass=$(awk '/keycloak_admin_password:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
sso_pass=$(awk '/sso_password:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
installer_log=/tmp/installerlog.txt

installSunbird

if [[ $? -ne 0 ]]; then
   echo -e "Installation failed - Retrying..." | tee -a $installer_log
   installSunbird
fi

if [[ $? -eq 0 ]]; then
   updateSSO
   coreInstall
else
   echo -e "Sunbird installation failed - Error occured during installation" | tee -a $installer_log
   postResult
fi

if [[ $? -eq 0 ]]; then
   systemInit
else
   echo -e "Sunbird installation failed - Error occured during core installation" | tee -a $installer_log
   postResult
fi

if [[ $? -eq 0 ]]; then
   postTest
else
   echo -e "Sunbird installation failed - Error occured during system initialization" | tee -a $installer_log
   postResult
fi

if [[ $? -eq 0 ]]; then
   copyLogs
   echo -e "Sunbird installation complete" | tee -a $installer_log
   echo "status: Success" >> $build_info
   echo "subject: $release build succeeded" >> $build_info
else
   echo -e "Sunbird installation failed - Error occured duing postTest" | tee -a $installer_log
   postResult
fi
