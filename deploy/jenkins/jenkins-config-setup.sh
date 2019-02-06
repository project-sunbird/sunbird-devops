#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\e[0;32m${bold}Jenkins configuration setup...${normal}"
read -p 'Jenkins URL without http://: ' server
read -p 'Jenkins admin username: ' username
read -sp 'Jenkins admin Password: ' password
mkdir jenkins_config
cd jenkins_config

echo -e "\e[0;32m${bold}Getting config files... ${normal}"
wget https://sunbirdpublic.blob.core.windows.net/installation/jenkins_config.zip
mkdir config_files
unzip -o jenkins_config.zip -d config_files
cd config_files


echo -e "\e[0;32m${bold}Copying config files to Jenkins ${normal}"
cp -r jobs /var/lib/jenkins

echo -e "\e[0;32m${bold}Installating plugins... ${normal}"
butler plugins i -s $server -u $username -p $password

echo -e "\e[0;32m${bold}Go to manage jenkins -> Plugin manager -> Update center -> Check restart jenkins after installation${normal}"

