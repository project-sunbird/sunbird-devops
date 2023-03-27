#!/bin/bash
NAMESPACE="lern"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo -e "\e[91mkubectl is not installed. Please install kubectl and try again.\e[0m"
  exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
  echo -e "\e[91mHelm is not installed. Please install Helm and try again.\e[0m"
  exit 1
fi

# Check if figlet is installed, and install it if it's not
if ! command -v figlet &> /dev/null; then
  echo -e "\e[93mfiglet is not installed, installing it now...\e[0m"
  sudo apt-get update
  sudo apt-get install figlet -y
fi

# Print Sunbird Learn ASCII art banner using figlet
figlet -f slant "Sunbird Learn Installation"

# Check if kubernetes cluster connection exists by trying to list pods
if ! kubectl get pods >/dev/null 2>&1; then
  echo -e "\e[91mCould not connect to Kubernetes cluster\e[0m"
  exit 1
fi

# Create the learn namespace if it doesn't exist
if ! kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
  kubectl create namespace $NAMESPACE
  echo -e "\e[92mCreated namespace $NAMESPACE\e[0m"
fi

chart_dir=$PWD

# Deploy the Helm charts from the current directory
for chart in */ ; do
  chart_name=$(basename $chart)
  if helm upgrade --install $chart_name $chart --namespace $NAMESPACE >/dev/null; then
    echo -e "\e[92mSuccessfully deployed ${chart_name}\e[0m"
  else
    echo -e "\e[91mFailed to deploy ${chart_name}\e[0m"
  fi
done



#Install helm chart 3.7.1 for chart installation
# curl -LO https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
# tar -zxvf helm-v3.7.1-linux-amd64.tar.gz
# sudo mv linux-amd64/helm /usr/local/bin/
# helm version
