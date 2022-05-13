#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\n\e[0;32m${bold}Clean up${normal}"
rm -rf /etc/apt/sources.list.d/azure-cli.list /etc/apt/sources.list.d/packages_microsoft_com_repos_azure_cli.list*

echo -e "\n\e[0;32m${bold}Updating the apt repo${normal}\n"
apt-get update

echo -e "\n\e[0;32m${bold}Installating JDK8${normal}\n"
apt-get install -y openjdk-8-jdk

echo -e "\n\e[0;32m${bold}Installating Jenkins${normal}"
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
apt-add-repository "deb https://pkg.jenkins.io/debian-stable binary/"
apt-get update
apt-get install -y jenkins=2.277.4

echo -e "\n\e[0;32m${bold}Installating PIP${normal}"
apt-get install -y python-pip
apt-get install -y python3-pip

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
wget https://nodejs.org/download/release/v6.17.1/node-v6.17.1-linux-x64.tar.gz
tar -xf node-v6.17.1-linux-x64.tar.gz
rm -rf /usr/local/lib/node-v6.17.1-linux-x64
rm -rf /usr/bin/node
rm -rf /usr/bin/npm
rm -rf /usr/bin/grunt
rm -rf /usr/bin/bower
rm -rf /usr/bin/gulp
mv node-v6.17.1-linux-x64 /usr/local/lib/
ln -s /usr/local/lib/node-v6.17.1-linux-x64/bin/node /usr/bin/node
ln -s /usr/local/lib/node-v6.17.1-linux-x64/bin/npm /usr/bin/npm
npm install -g grunt-cli@1.2.0
ln -s /usr/local/lib/node-v6.17.1-linux-x64/bin/grunt /usr/bin/grunt
npm install -g bower@1.8.0
ln -s /usr/local/lib/node-v6.17.1-linux-x64/bin/bower /usr/bin/bower
npm install -g @alexlafroscia/yaml-merge
ln -s /var/lib/jenkins/.nvm/versions/node/v12.16.1/bin/yaml-merge /usr/bin/yaml-merge
npm install -g gulp@3.9.1
ln -s /usr/local/lib/node-v6.17.1-linux-x64/bin/gulp /usr/bin/gulp
rm -rf node-v6.17.1-linux-x64*

echo -e "\n\e[0;32m${bold}Installating Ansible${normal}"
pip uninstall -y ansible
pip3 install ansible==2.8.19

echo -e "\n\e[0;32m${bold}Installating azure cli${normal}"
apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install azure-cli

# Install azcopy
echo -e "\n\e[0;32m${bold}Installating AzCopy${normal}"
apt update
wget https://aka.ms/downloadazcopy-v10-linux
tar -xf downloadazcopy-v10-linux
cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
rm -rf downloadazcopy-v10-linux* azcopy_linux_amd*
###

echo -e "\n\e[0;32m${bold}Installating pip docker${normal}"
pip install docker
pip3 install docker

echo -e "\n\e[0;32m${bold}Installating colordiff${normal}"
apt-get install -y colordiff

echo -e "\n\e[0;32m${bold}Adding jenkins user to docker group${normal}"
usermod -aG docker jenkins

echo -e "\n\e[0;32m${bold}Creating bashrc for jenkins user ${normal}"
cp /etc/skel/.bashrc /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins/.bashrc

echo -e "\n\e[0;32m${bold}Setting timezone to IST ${normal}"
timedatectl set-timezone Asia/Kolkata

echo -e "\n\e[0;32m${bold}Installing nvm${normal}"
su jenkins bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash"

echo -e "\n\e[0;32m${bold}Installing jmespath${normal}"
sudo apt install -y python3-jmespath

#### Kubernetes Tools ####

# Install Helm version 3.0.2
echo -e "\n\e[0;32m${bold}Installating Helm${normal}"
wget https://get.helm.sh/helm-v3.0.2-linux-386.tar.gz
tar -xzvf helm-v3.0.2-linux-386.tar.gz
rm -rf /usr/local/bin/helm
cp linux-386/helm /usr/local/bin/helm
rm -rf helm-v* linux-amd*

# Install kubectl v1.22.0
echo -e "\n\e[0;32m${bold}Installating kubectl${normal}"
curl -LO https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin

#Install yarn
echo -e "\n\e[0;32m${bold}Installating yarn${normal}"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt update && apt install -y yarn

#Install openjdk
echo -e "\n\e[0;32m${bold}Installating openjdk 11${normal}"
wget https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_linux-x64_bin.tar.gz
tar -xf openjdk-11+28_linux-x64_bin.tar.gz
mv jdk-11 java-11-openjdk-amd64
cp -r java-11-openjdk-amd64 /usr/lib/jvm/
rm -rf java-11-openjdk-amd64 openjdk-11+28_linux-x64_bin.tar.gz

#Install maven 3.6.3
echo -e "\n\e[0;32m${bold}Installating maven 3.6.3${normal}"
wget https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar -xf apache-maven-3.6.3-bin.tar.gz
mv apache-maven-3.6.3 /opt/
mv /opt/apache-maven-3.6.3/bin/mvn /opt/apache-maven-3.6.3/bin/mvn3.6
rm -rf apache-maven-3.6.3-bin.tar.gz

#Install python-psycopg2
echo -e "\n\e[0;32m${bold}Installating python-psycopg2${normal}"
apt install -y python-psycopg2

#Install libpng-dev - Ubuntu 18 and above fix for plugin builds
echo -e "\n\e[0;32m${bold}Installating libpng-dev${normal}"
apt install -y libpng-dev

echo -e "\n\e[0;32m${bold}Installating OPA${normal}"
curl -k -L -o opa https://openpolicyagent.org/downloads/v0.34.2/opa_linux_amd64_static
chmod 755 ./opa
mv opa /usr/local/bin/

echo -e "\n\e[0;32m${bold}Installing mongo tools${normal}"
apt install -y mongo-tools

echo -e "\n\e[0;32m${bold}Installing required python2 pacakges if distro is ubuntu 18 and above${normal}"
# For kong api and consumer onboarding
osrelease=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | awk -F '=' '{print $2}')
if [[ $osrelease > 18 ]]
then
  wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
  which pip
  rc=$?
  if [[ $rc == 0 ]]
  then
    cp /usr/local/bin/pip /usr/local/bin/pip3
  fi
  which python2.7
  rc=$?
  if [[ $rc == 0 ]]
  then
    python2.7 get-pip.py
    pip install retry
    pip install PyJWT
    apt reinstall -y python3-pip
  else
    apt reinstall -y python2
    python2.7 get-pip.py
    python2.7 get-pip.py
    pip install PyJWT
    apt reinstall -y python3-pip
  fi
fi
rm -rf get-pip.py

echo -e "\n\e[0;32m${bold}Clean up${normal}"
sudo apt -y autoremove

echo -e "\n\e[0;32m${bold}Installation complete. Please go to your jenkins URL and continue setup if this is the first run..${normal}"
