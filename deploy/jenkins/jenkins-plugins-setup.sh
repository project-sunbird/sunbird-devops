#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

if [[ ! -d /var/lib/jenkins/.m2 ]]; then
echo -e "\n\e[0;32m${bold}Downloading and copying m2 directory to Jenkins ${normal}"
wget https://sunbirdpublic.blob.core.windows.net/installation/m2-slim.tar
tar -xf m2-slim.tar
mv .m2 /var/lib/jenkins
chown -R jenkins:jenkins /var/lib/jenkins/.m2
else
wget https://sunbirdpublic.blob.core.windows.net/installation/m2-slim.tar
tar -xf m2-slim.tar
cp -rf .m2/* /var/lib/jenkins/.m2/
chown -R jenkins:jenkins /var/lib/jenkins/.m2
fi

echo -e "\n\e[0;32m${bold}Downloading and copying jenkins plugin directory to Jenkins ${normal}"
if [[ ! -d /var/lib/jenkins/plugins ]]; then
wget https://sunbirdpublic.blob.core.windows.net/installation/plugins.tar
tar -xf plugins.tar
mv plugins /var/lib/jenkins/
chown -R jenkins:jenkins /var/lib/jenkins/plugins
else
wget https://sunbirdpublic.blob.core.windows.net/installation/plugins.tar
tar -xf plugins.tar
cp -rf plugins/* /var/lib/jenkins/plugins/
chown -R jenkins:jenkins /var/lib/jenkins/plugins
fi

echo -e "\n\e[0;32m${bold}Go to manage jenkins -> Plugin manager -> Update center -> Check status of installation OR Check the list of installed plugins${normal}"
