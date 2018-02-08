#!/bin/sh
# Build script
# set -o errexit

docker_version=17.06.2~ce-0~ubuntu
ansible_version=2.4.1.0
swarm_master_ip=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
echo "MasterIP: $swarm_master_ip"

# Check for docker
case "$(docker --version)" in
    *17.06.2-ce*)
        ;;
    *)
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
    apt-get -y install docker-ce=$docker_version

    # Setup docker to system service
    systemctl enable docker
    systemctl restart docker

    # Initialise Docker Swarm, with current machine as Master (which is active)
    docker swarm init --advertise-addr $swarm_master_ip

    docker node ls
    ;;
esac

# Checking for ansible
case "$(ansible --version | head -n1)" in 
    *2.4.1.0*)
        ;;
     *)
    # Install Ansible
    sudo apt install -y python-pip
    sudo pip install ansible==$ansible_version
    ;;
esac
