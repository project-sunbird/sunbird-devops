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
      echo -e "Installing sunbird $var2" | tee -a $installer_log
   else
      git checkout -b $var1 origin/$var1
      echo -e "Installing sunbird $var1" | tee -a $installer_log
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

installSunbird(){
   echo -e "Starting installation..." | tee -a $installer_log
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

archiveLogs(){
   sudo apt install -y zip
   cp $installer_log logs
   zip -r /tmp/serverlogs.zip logs
}

sendEmail(){
   python /tmp/send_email.py
}

postResult(){
   echo "failed" >> /tmp/release_to_build
   echo "Release $release build failed" >> /tmp/release_to_build
   archiveLogs
   sendEmail
   exit 1
}

config_file=/tmp/config.yml.sample
release=$(cat /tmp/release_to_build | head -1)
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
   echo -e "Sunbird installation complete" | tee -a $installer_log
   echo "success" >> /tmp/release_to_build
   echo "Release $release build succeeded" >> /tmp/release_to_build
   archiveLogs
   sendEmail
else
   echo -e "Sunbird installation failed - Error occured duing postTest" | tee -a $installer_log
   postResult
fi
