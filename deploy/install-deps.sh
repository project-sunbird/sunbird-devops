#!/bin/sh
# Build script
# set -o errexit

ansible_version=2.5.0.0

# Checking for ansible
case "$(ansible --version 2> /dev/null | head -n1)" in 
    *2.5.0*)
      echo "$(ansible --version)"
      echo
        ;;
     *)
    # Install Ansible
    sudo apt update 
    sudo apt install -y  python python-pkg-resources python-pip
    sudo pip install ansible==$ansible_version
    ;;
esac

# Checking kube
case "$(kubectl version --short 2> /dev/null | awk 'END {print}')" in 
    Server*)
        echo "Kubernets version:\n$(kubectl version --short)"
        echo
        ;;
     *)
    # Install kubernetes
    curl -sL https://get.k3s.io | INSTALL_K3S_VERSION=v0.9.0 INSTALL_K3S_EXEC="--no-deploy=traefik --no-deploy=servicelb" sh -
    sudo chown $(whoami) /etc/rancher/k3s/k3s.yaml
    ;;
esac

# Checking helm3
case "$(helm version 2> /dev/null)" in 
    *version*)
        echo "Helm version:\n$(helm version --short)"
        echo
        ;;
     *)
    # Install helm
    curl -sLO https://get.helm.sh/helm-v3.0.0-linux-amd64.tar.gz
    tar --strip 1 -xf  helm-v3.0.0-linux-amd64.tar.gz && rm helm-v3.0.0-linux-amd64.tar.gz
    sudo mv helm /usr/local/bin
    ;;
esac
