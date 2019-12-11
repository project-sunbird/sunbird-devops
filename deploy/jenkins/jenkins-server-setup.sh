#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\n\e[0;32m${bold}Updating the apt repo${normal}\n"
apt-get update

echo -e "\n\e[0;32m${bold}Installating JDK8${normal}\n"
apt-get install -y openjdk-8-jdk

echo -e "\n\e[0;32m${bold}Installating Jenkins${normal}"
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
apt-add-repository "deb https://pkg.jenkins.io/debian-stable binary/"
apt-get update
apt-get install -y jenkins=2.176.2

echo -e "\n\e[0;32m${bold}Installating PIP${normal}"
apt-get install -y python-pip

echo -e "\n\e[0;32m${bold}Installating Maven${normal}"
apt-get install -y maven

echo -e "\n\e[0;32m${bold}Installating Git ${normal}"
apt-get install -y git

echo -e "\n\e[0;32m${bold}Installating zip unzip${normal}"
apt-get install -y unzip zip

echo -e "\n\e[0;32m${bold}Installating JQ${normal}"
apt-get install -y jq

echo -e "\n\e[0;32m${bold}Installating Simplejson${normal}"
apt-get install -y python-simplejson

echo -e "\n\e[0;32m${bold}Installating tree${normal}"
apt install tree -y

echo -e "\n\e[0;32m${bold}Installating Docker${normal}"
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

echo -e "\n\e[0;32m${bold}Installating node and npm modules"
wget https://nodejs.org/download/release/v6.1.0/node-v6.1.0-linux-x64.tar.gz
tar -xvf node-v6.1.0-linux-x64.tar.gz
mv node-v6.1.0-linux-x64 /usr/local/lib/
ln -s /usr/local/lib/node-v6.1.0-linux-x64/bin/node /usr/bin/node
ln -s /usr/local/lib/node-v6.1.0-linux-x64/bin/npm /usr/bin/npm
npm install -g grunt-cli@1.2.0
ln -s /usr/local/lib/node-v6.1.0-linux-x64/bin/grunt /usr/bin/grunt
npm install -g bower@1.8.0
ln -s /usr/local/lib/node-v6.1.0-linux-x64/bin/bower /usr/bin/bower
npm install -g gulp@3.9.1
ln -s /usr/local/lib/node-v6.1.0-linux-x64/bin/gulp /usr/bin/gulp

echo -e "\n\e[0;32m${bold}Installating Ansible${normal}"
pip install ansible==2.5.0

echo -e "\n\e[0;32m${bold}Installating azure cli${normal}"
apt-get install curl apt-transport-https lsb-release gpg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

apt-get update
apt-get install azure-cli

# Install azcopy
echo -e "\n\e[0;32m${bold}Installating AzCopy${normal}"
apt update
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux
cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
rm -rf downloadazcopy-v10-linux* azcopy_linux_amd*
###

echo -e "\n\e[0;32m${bold}Installating Docker-py${normal}"
pip install docker-py

echo -e "\n\e[0;32m${bold}Installating colordiff${normal}"
apt-get install -y colordiff

echo -e "\n\e[0;32m${bold}Installating git lfs${normal}"
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
apt-get install git-lfs

echo -e "\n\e[0;32m${bold}Adding jenkins user to docker group${normal}"
usermod -aG docker jenkins

echo -e "\n\e[0;32m${bold}Creating bashrc for jenkins user ${normal}"
cp /etc/skel/.bashrc /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins/.bashrc

echo -e "\n\e[0;32m${bold}Installation complete. Please go to your jenkins URL and continue setup if this first run..${normal}"
