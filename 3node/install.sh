#!/bin/bash
echo Installing k8s cluster

if [[ ! $(kubectl get po) ]]; then
    curl -L https://get.k3s.io | INSTALL_K3S_VERSION=v0.9.0 INSTALL_K3S_EXEC="--no-deploy=traefik --no-deploy=servicelb" sh -
    sudo chown $(whoami) /etc/rancher/k3s/k3s.yaml
fi

echo 'Installing helm3'
curl -LO https://get.helm.sh/helm-v3.0.0-linux-amd64.tar.gz
tar --strip 1 -xf  helm-v3.0.0-linux-amd64.tar.gz && rm helm-v3.0.0-linux-amd64.tar.gz
sudo mv helm /usr/local/bin

