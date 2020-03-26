#!/bin/sh
# Build script
set -eu -o pipefail

# This is to fix cross terminal compatibility
export LC_ALL=C

ansible_version=2.5.0.0
source 3node.vars

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

# Installing az cli
[[ $(which az) ]] || (curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash)

# Installing jq
[[ $(which jq) ]] || sudo apt install jq -y

# Checking kube
case "$(kubectl version --short 2> /dev/null | awk 'END {print}')" in 
    *v1.16*)
        echo "Kubernets version:\n$(kubectl version --short)"
        echo
        ;;
     *)
    # Install kubernetes
    curl -sL https://get.k3s.io | INSTALL_K3S_VERSION=v1.0.1 INSTALL_K3S_EXEC="--kubelet-arg containerd=/run/k3s/containerd/containerd.sock --no-deploy=traefik --no-deploy=local-storage --no-deploy=metrics-server --tls-san ${domain_name}" sh -
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
