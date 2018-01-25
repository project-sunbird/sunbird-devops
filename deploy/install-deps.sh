#!/bin/sh
# Build script
# set -o errexit

DOCKER_VERSION=17.06.2~ce-0~ubuntu
ANSIBLE_VERSION=2.4.1.0
SWARM_MASTER_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
echo "MasterIP: $SWARM_MASTER_IP"

# Remove other versions of docker
apt-get -y remove docker docker-engine docker.io

# Install extra packages needed for docker
apt-get -y update && \
  apt-get -y install \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

# Setup docker repository
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get -y update

# Install Docker engine
apt-get -y install docker-ce=$DOCKER_VERSION

# Install Ansible
apt install -y python-pip
pip install ansible==$ANSIBLE_VERSION

# Setup docker to system service
systemctl enable docker
systemctl restart docker

# Initialise Docker Swarm, with current machine as Master (which is active)
docker swarm init --advertise-addr $SWARM_MASTER_IP

docker node ls
