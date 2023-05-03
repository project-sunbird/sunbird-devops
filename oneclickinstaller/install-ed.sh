#!/bin/bash
# set -x
# Set the namespace for the Helm charts
namespace="dev"
kubeconfig_file=$1

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo -e "\e[91mkubectl is not installed. Installing kubectl...\e[0m"
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
  if [ $? -eq 0 ]; then
    echo -e "\e[92mkubectl installed successfully.\e[0m"
  else
    echo -e "\e[91mFailed to install kubectl. Please install kubectl manually and try again.\e[0m"
    exit 1
  fi
else
  echo -e "\e[92mkubectl is already installed.\e[0m"
fi



# Check if helm is installed
if ! command -v helm &> /dev/null; then
  echo -e "\e[91mHelm is not installed. Installing Helm...\e[0m"
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  if [ $? -eq 0 ]; then
    echo -e "\e[92mHelm installed successfully.\e[0m"
  else
    echo -e "\e[91mFailed to install Helm. Please install Helm manually and try again.\e[0m"
    exit 1
  fi
else
  echo -e "\e[92mHelm is already installed.\e[0m"
fi


# Check if figlet is installed, and install it if it's not
if ! command -v figlet &> /dev/null; then
  echo -e "\e[93mfiglet is not installed, installing it now...\e[0m"
  sudo apt-get update
  sudo apt-get install figlet -y
fi

# Print Sunbird Obsrv ASCII art banner using figlet
figlet -f slant "Sunbird Ed Installation"

# Check if the kubeconfig file exists
if [ ! -f "$kubeconfig_file" ]; then
    echo "Error: Kubeconfig file not found."
    exit 1
fi

# Check connectivity with the Kubernetes cluster
kubectl --kubeconfig="$kubeconfig_file" cluster-info >/dev/null 2>&1
export KUBECONFIG="$kubeconfig_file"
if [ $? -ne 0 ]; then
    echo "Error: Unable to connect to the Kubernetes cluster with the provided kubeconfig file."
    exit 1
fi

echo "Success: Connected to the Kubernetes cluster with the provided kubeconfig file."

### Trigger Lern Installer 
./install-lern.sh $kubeconfig_file 

### Trigger Observ Installer 
./install-obsrv.sh $kubeconfig_file

### Trigger InQuiry Installer 
./install-inquiry.sh $kubeconfig_file

### Trigger Knowlg Installer
./install-knowlg.sh $kubeconfig_file

# Create the ed namespace if it doesn't exist
if ! kubectl get namespace $namespace >/dev/null 2>&1; then
  kubectl create namespace $namespace
  echo -e "\e[92mCreated namespace $namespace\e[0m"
fi

# Check if the ed-charts.csv file exists
if [ ! -f "ed-charts.csv" ]; then
  echo "Error: ed-charts.csv file not found"
  exit 1
fi

while IFS=',' read -r chart_name chart_repo; do
  # Check if the chart repository URL is empty
  if [ -z "$chart_repo" ]; then
    echo "Error: Repository URL not found for $chart_name in ed-charts.csv"
    exit 1
  fi

  # # Check if the chart is already installed
  # if helm list -n "$namespace" | grep -q "$chart_name"; then
  #   echo -e "\e[92m$chart_name is already installed\e[0m"
  # else
    # Install the chart with global variables
    if ! helm upgrade --install "$chart_name" "$chart_repo" -n "$namespace" -f global-values.yaml -f ed-sample-values.yml ; then
      echo -e "\e[91mError installing $chart_name\e[0m"
   #   exit 1
   fi
    echo -e "\e[92m$chart_name is installed successfully\e[0m"
  # fi
done < ed-charts.csv