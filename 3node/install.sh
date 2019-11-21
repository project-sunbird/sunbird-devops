#!/bin/bash
echo Installing k8s cluster

curl -L https://get.k3s.io | INSTALL_K3S_VERSION=v0.9.0 INSTALL_K3S_EXEC="--no-deploy=traefik --no-deploy=servicelb" sh -
sudo chown $(whoami) /etc/rancher/k3s/k3s.yaml
