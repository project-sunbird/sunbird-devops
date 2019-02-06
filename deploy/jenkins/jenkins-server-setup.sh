#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
echo -e "\e[0;32m${bold}Installating JDK8${normal}\n"
apt-get install -y openjdk-8-jdk-headless

echo -e "\e[0;32m${bold}Installating Jenkins${normal}"
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
echo "deb https://pkg.jenkins.io/debian binary/" >> /etc/apt/sources.list
apt-get update
apt-get install -y jenkins

echo -e "\e[0;32m${bold}Starting Jenkins service${normal}"
service jenkins start

echo -e "\e[0;32m${bold}Installating PIP${normal}"
apt-get install -y python-pip

echo -e "\e[0;32m${bold}Installating Maven${normal}"
apt-get install -y maven

echo -e "\e[0;32m${bold}Installating Git ${normal}"
apt-get install -y git

echo -e "\e[0;32m${bold}Installating zip unzip${normal}"
apt-get install -y unzip zip

echo -e "\e[0;32m${bold}Installating JQ${normal}"
apt-get install -y jq

echo -e "\e[0;32m${bold}Installating Simplejson${normal}"
apt-get install -y python-simplejson

echo -e "\e[0;32m${bold}Installating Docker${normal}"
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

echo -e "\e[0;32m${bold}Installating Ansible${normal}"
pip install ansible==2.5.0

echo -e "\e[0;32m${bold}Installating Docker-py${normal}"
pip install docker-py

echo -e "\e[0;32m${bold}Adding jenkins user to docker group${normal}"
usermod -G docker jenkins

echo -e "\e[0;32m${bold}Creating bashrc for jenkins user ${normal}"
cp /etc/skel/.bashrc /var/lib/jenkins

echo -e "\e[0;32m${bold}Getting jenkins config script for next steps${normal}"
mv jenkins-config-setup.sh /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins/jenkins-config-setup.sh
chmod 755 /var/lib/jenkins/jenkins-config-setup.sh

echo -e "\e[0;32m${bold}Installation complete. Please go to your jenkins URL and continue setup${normal}"
