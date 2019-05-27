#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\n\e[0;32m${bold}Updating the apt repo${normal}\n"
apt-get update

echo -e "\n\e[0;32m${bold}Installating JDK8${normal}\n"
apt-get install -y openjdk-8-jdk

echo -e "\n\e[0;32m${bold}Installating PIP${normal}"
apt-get install -y python-pip

echo -e "\n\e[0;32m${bold}Installating Git ${normal}"
apt-get install -y git

echo -e "\n\e[0;32m${bold}Installating zip unzip${normal}"
apt-get install -y unzip zip

echo -e "\n\e[0;32m${bold}Installating JQ${normal}"
apt-get install -y jq

echo -e "\n\e[0;32m${bold}Installating node and npm modules"
wget https://nodejs.org/download/release/v6.1.0/node-v6.1.0-linux-x64.tar.gz
tar -xvf node-v6.1.0-linux-x64.tar.gz
mv node-v6.1.0-linux-x64 /usr/local/lib/
ln -s /usr/local/lib/node-v6.1.0-linux-x64/bin/node /usr/bin/node
ln -s /usr/local/lib/node-v6.1.0-linux-x64/bin/npm /usr/bin/npm
npm install -g gulp@3.9.1
ln -s /usr/local/lib/node-v6.1.0-linux-x64/bin/gulp /usr/bin/gulp

echo -e "\n\e[0;32m${bold}Installating Ansible${normal}"
pip install ansible==2.5.0

echo -e "\n\e[0;32m${bold}Installating Docker-py${normal}"
pip install docker-py

echo -e "\n\e[0;32m${bold}Adding jenkins user to docker group${normal}"
useradd -m -d /var/lib/jenkins -s /bin/bash -c "Jenkins user" -U jenkins

echo -e "\n\e[0;32m${bold}Jenkins slave installation complete..${normal}"
