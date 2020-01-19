#!/bin/bash

BOLD="$(tput bold)"
GREEN="${BOLD}$(tput setaf 2)"
YELLOW="${BOLD}$(tput setaf 3)"
WHITE="$(tput sgr0)${BOLD}"
NORMAL="$(tput sgr0)"
source 3node.vars


export KUBECONFIG=/etc/rancher/k3s/k3s.yaml:${HOME}/.kube/config
sunbird_path=${HOME}/sunbird-devops

echo -e "${GREEN}Installing rancher ${NORMAL}"
kubectl apply -f ${sunbird_path}/kubernetes/helm_charts/cattle-system/rancher.yaml > /dev/null

echo -e "${GREEN}Installing stern ${NORMAL}"
sudo curl -LSs https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64 -o /usr/local/bin/stern

echo -e "${GREEN}Enabling kubectl autocompletion ${NORMAL}"
cat >> ~/.bashrc <<EOF
source <(kubectl completion bash)
source <(stern --completion=bash)
alias k=kubectl
complete -F __start_kubectl k
EOF

echo -e "${GREEN}Enabling kubeconfig ${NORMAL}"
kubectl config view --flatten > ~/.kube/config

ipaddress=$(curl -Ss ifconfig.co)

cat << EOF
${GREEN}

Yay !! 

Sunbird installation is complete

open ${WHITE}https://${domain_name}${GREEN}

your admin user is: ${WHITE}${username}${GREEN}
password : ${WHITE}${password}${GREEN}

${GREEN}
Rancher is to manage the cluster
open following link in browser and accept the ssl certificate
${YELLOW}
https://${ipaddress}:8443
${GREEN}
1. Create password
2. Add ${YELLOW}$(hostname -i):8443${GREEN} as server-url

${GREEN}
To see the logs of pods from cli of remote machine; for example
to see nginx logs
${YELLOW}
stern --namespace dev nginx
${GREEN}

To interact with your kubernetes cluster, use kubectl; for example
${YELLOW}kubectl get all --all-namespaces
${NORMAL}
EOF
