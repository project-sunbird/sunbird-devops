#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\n\e[0;32m${bold}Updating the apt repo${normal}\n"
apt update

echo -e "\n\e[0;32m${bold}Installating JDK11${normal}\n"
apt install -y openjdk-11-jdk

echo -e "\n\e[0;32m${bold}Installating Git ${normal}"
apt install -y git

echo -e "\n\e[0;32m${bold}Installating zip unzip${normal}"
apt install -y unzip zip

echo -e "\n\e[0;32m${bold}Installating JQ${normal}"
apt install -y jq

echo -e "\n\e[0;32m${bold}Installating Gradle-6.5.1${normal}"
wget -O gradle-6.5.1.zip https://services.gradle.org/distributions/gradle-6.5.1-all.zip
unzip -q gradle-6.5.1.zip
mkdir -p /usr/lib/gradle
mv gradle-6.5.1 6.5.1
sudo mv 6.5.1 /usr/lib/gradle/

echo -e "\n\e[0;32m${bold}Installating Gradle-7.4.1${normal}"
wget -O gradle-7.4.1.zip 'https://services.gradle.org/distributions/gradle-7.4.1-all.zip'
unzip -q gradle-7.4.1.zip
mkdir -p /opt/gradle
mv gradle-7.4.1 /opt/gradle/

echo -e "\n\e[0;32m${bold}Installating node"
wget https://nodejs.org/download/release/v12.20.0/node-v12.20.0-linux-x64.tar.gz
tar -xvf node-v12.20.0-linux-x64.tar.gz
mv node-v12.20.0-linux-x64 /usr/local/lib/
ln -s /usr/local/lib/node-v12.20.0-linux-x64/bin/node /usr/bin/node
ln -s /usr/local/lib/node-v12.20.0-linux-x64/bin/npm /usr/bin/npm

echo -e "\n\e[0;32m${bold}Installating node modules"
npm install -g ionic
npm install -g cordova@10.0.0
npm install -g cordova-res
ln -s /usr/local/lib/node-v12.20.0-linux-x64/bin/ionic /usr/bin/ionic
ln -s /usr/local/lib/node-v12.20.0-linux-x64/bin/cordova /usr/bin/cordova

echo -e "\n\e[0;32m${bold}Jenkins slave installation complete..${normal}"