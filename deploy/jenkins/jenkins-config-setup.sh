#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\n\e[0;32m${bold}Restarting Jenkins service${normal}"
service jenkins restart

echo -e "\e[0;32m${bold}Jenkins configuration setup...${normal}"
read -p 'Jenkins URL without http://: ' server
read -p 'Jenkins admin username: ' username
read -sp 'Jenkins admin Password: ' password

echo -e "\n\e[0;32m${bold}Copying config files to Jenkins ${normal}"
rsync -r jobs /var/lib/jenkins/
chown -R jenkins:jenkins /var/lib/jenkins/jobs

echo -e "\n\e[0;32m${bold}Downloading and copying m2 directory to Jenkins ${normal}"
wget https://sunbirdpublic.blob.core.windows.net/installation/m2_updated.zip
unzip m2_updated.zip
mv .m2 /var/lib/jenkins
chown -R jenkins:jenkins /var/lib/jenkins/.m2

echo -e "\n\e[0;32m${bold}Installating plugins... ${normal}"
./butler plugins i -s $server -u $username -p $password
wget https://sunbirdpublic.blob.core.windows.net/installation/hudson.plugins.ansicolor.AnsiColorBuildWrapper.xml
rm /var/lib/jenkins/hudson.plugins.ansicolor.AnsiColorBuildWrapper.xml
mv hudson.plugins.ansicolor.AnsiColorBuildWrapper.xml /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins/hudson.plugins.ansicolor.AnsiColorBuildWrapper.xml

echo -e "\n\e[0;32m${bold}Go to manage jenkins -> Plugin manager -> Update center -> Check restart jenkins after installation${normal}"
