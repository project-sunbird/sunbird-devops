#!/bin/bash

copyPem(){
   mkdir /home/$username/.ssh 2> /dev/null
   cp /tmp/sunbird.pem /home/$username/.ssh
}

checkoutRepo(){
   cd /home/$username
   git clone https://github.com/project-sunbird/sunbird-devops.git
   cd sunbird-devops
   IFS="/" read -r var1 var2 <<< $release
   if [[ $var1 == "tags" ]]; then
      git checkout $release -b $var2
      echo -e "Installing sunbird $var2" | tee $installer_log
   else
      git checkout -b $var1 origin/$var1
      echo -e "Installing sunbird $var1" | tee $installer_log
   fi
}

copyConfig(){
   cd deploy
   if [[ -f config ]]; then
      cp $config_file config
      config_file=config
   else
      cp $config_file config.yml
      config_file=config.yml
   fi
}

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
   echo -e "Sunbird installation complete - Starting core installation..." | tee $installer_log
   bash sunbird_install.sh -s core
}

createRootOrg(){
   jwt_token=$(cat /home/$username/jwt_token_player.txt | tr -d " ")
   access_token_user=$(curl -s -X POST http://$dns_name/auth/realms/sunbird/protocol/openid-connect/token -H "cache-control: no-cache" -H "content-type: application/x-www-form-urlencoded" -d "client_id=admin-cli&username=user-manager&password=$sso_pass&grant_type=password" | jq -r ".access_token")
   status=$(curl -s -X POST  http://$dns_name/api/org/v1/create -H "Cache-Control: no-cache" -H "Content-Type: application/json" -H "accept: application/json" -H "authorization: Bearer $jwt_token" -H "x-authenticated-user-token: $access_token_user" -d '{"request":{"orgName": "circle-ci", "description": "circle-ci", "isRootOrg": true, "channel": "circle-ci"}}' | jq -r ".result.response")
}

postTest(){
   bash sunbird_install.sh -s posttest
}

archiveLogs(){
   cp $installer_log logs
   zip -r /tmp/serverlogs.zip logs
}

sendEmail(){
   python /tmp/send_email.py
}

postResult(){
   echo "failed" >> /tmp/release_to_build
   archiveLogs
   sendEmail
   exit 1
}

config_file=/tmp/config.yml.sample
release=$(cat /tmp/release_to_build)
username=$(awk '/ssh_ansible_user:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
dns_name=$(awk '/dns_name:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
keycloak_pass=$(awk '/keycloak_admin_password:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
sso_pass=$(awk '/sso_password:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
installer_log=/tmp/installerLog.txt

copyPem
checkoutRepo
copyConfig
installSunbird

if [[ $? -ne 0 ]]; then
   echo -e "Installation failed - Retrying..." | tee $installer_log
   installSunbird
fi

if [[ $? -eq 0 ]]; then
   updateSSO
   coreInstall
else
   echo -e "Sunbird installation failed - Error occured during installation" | tee $installer_log
   postResult
fi

if [[ $? -eq 0 ]]; then
   createRootOrg
else
   echo -e "Sunbird installation failed - Error occured during core installation" | tee $installer_log
   postResult
fi

if [[ $status == "SUCCESS" ]]; then
   echo -e "Root org created successfully - Running core install..." | tee $installer_log
   coreInstall
else
   echo -e "Sunbird installation failed - Unable to create root org" | tee $installer_log
   postResult
fi

if [[ $? -eq 0 ]]; then
   postTest
else
   echo -e "Sunbird installation failed - Error occured during core installation after creating root org" | tee $installer_log
   postResult
fi

if [[ $? -eq 0 ]]; then
   echo -e "Sunbird installation complete" | tee $installer_log
   echo "succeeded" >> /tmp/release_to_build
   archiveLogs
   sendEmail
else
   echo -e "Sunbird installation failed - Error occured duing postTest" | tee $installer_log
   postResult
fi
