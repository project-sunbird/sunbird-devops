#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\e[0;32m${bold}Jenkins configuration setup...${normal}"
read -p 'Jenkins URL without http://: ' server
read -p 'Jenkins admin username: ' username
read -sp 'Jenkins admin Password: ' password

if [[ ! -d /var/lib/jenkins/.m2 ]]; then
echo -e "\n\e[0;32m${bold}Downloading and copying m2 directory to Jenkins ${normal}"
wget https://sunbirdpublic.blob.core.windows.net/installation/m2_new.zip
unzip m2_new.zip
mv .m2 /var/lib/jenkins
chown -R jenkins:jenkins /var/lib/jenkins/.m2
fi

echo -e "\n\e[0;32m${bold}Installating plugins... ${normal}"
./butler plugins i -s $server -u $username -p $password

echo -e "\n\e[0;32m${bold}Go to manage jenkins -> Plugin manager -> Update center -> Check status of installation${normal}"
