#!/bin/bash
# Set the namespace for the Helm charts
namespace="dock"

# Check if kubeconfig file is provided as argument
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [kubeconfig_file] [cokreat | postscript]"
  exit 1
else
  kubeconfig_file=$1
  shift
fi

# Set kubectl context
export KUBECONFIG="$kubeconfig_file"

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


# Check if the kubeconfig file exists
if [ ! -f "$kubeconfig_file" ]; then
  echo "Error: Kubeconfig file not found."
  exit 1
fi

# Check connectivity with the Kubernetes cluster
kubectl --kubeconfig="$kubeconfig_file" cluster-info >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Unable to connect to the Kubernetes cluster with the provided kubeconfig file."
    exit 1
fi

echo "Success: Connected to the Kubernetes cluster with the provided kubeconfig file."



# Create the ed namespace if it doesn't exist
if ! kubectl get namespace $namespace >/dev/null 2>&1; then
  kubectl create namespace $namespace
  echo -e "\e[92mCreated namespace $namespace\e[0m"
fi

# Check if the cokreat-charts.csv file exists
if [ ! -f "cokreat-charts.csv" ]; then
  echo "Error: cokreat-charts.csv file not found"
  exit 1
fi

cokreat() {
figlet -f slant "Sunbird cokreat Installation"
### Update variables 
AccountName=$(grep "cloud_public_storage_accountname" global-values.yaml | awk -F ":" '{if($1=="cloud_public_storage_accountname") print $2}' | awk '{print $1}')
AccountKey=$(grep "cloud_public_storage_secret" global-values.yaml | awk -F ":" '{if($1=="cloud_public_storage_secret") print $2}' | awk '{print $1}')
AccountNameStriped=$(grep "cloud_public_storage_accountname" global-values.yaml | awk -F ":" '{if($1=="cloud_public_storage_accountname") print $2}' | awk '{print $1}' | sed 's/^.\(.*\).$/\1/')
echo "cloud_private_storage_accountname: $AccountName" >> global-values.yaml
echo "cloud_storage_key: $AccountName" >> global-values.yaml
echo "sunbird_azure_account_name: $AccountName" >> global-values.yaml
echo "cloud_storage_base_url: \"https://$AccountNameStriped.blob.core.windows.net\"" >> global-values.yaml
echo "cloud_storage_cname_url: \"https://$AccountNameStriped.blob.core.windows.net\"" >> global-values.yaml
echo "sunbird_azure_storage_account_name: \"https://$AccountNameStriped.blob.core.windows.net\"" >> global-values.yaml
echo "sunbird_image_storage_url: \"https://$AccountNameStriped.blob.core.windows.net/dial/\"" >> global-values.yaml
echo "cloud_private_storage_secret: $AccountKey" >> global-values.yaml
echo "cloud_storage_secret: $AccountKey" >> global-values.yaml
echo "sunbird_azure_account_key: $AccountKey" >> global-values.yaml

# Get the job logs and search for the tokens for onboardconsumer
LOGS=$(kubectl logs -l job-name=onboardconsumer -n dev --tail=10000)
# Extract the JWT token from the logs
TOKEN_LINE=$(echo "$LOGS" | grep "JWT token for api-admin is")
# Use awk to extract the token from the line
TOKEN=$(echo "$TOKEN_LINE" | awk -F' : ' '{print $2}')
echo "PORTAL_API_KEY: \"$TOKEN\"" >> global-values.yaml
echo "ANALYTICS_API_KEY: \"$TOKEN\"" >> global-values.yaml
echo "core_vault_sunbird_api_auth_token: \"$TOKEN\"" >> global-values.yaml

# ED Public Loadbalancer IP
ed_public_ingress_external_ip=$(kubectl -n dev get service nginx-public-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Check if the external IP is available
if [[ -n $ed_public_ingress_external_ip ]]; then
  echo "ED Public Ingress IP: $ed_public_ingress_external_ip"
  echo "CORE_INGRESS_GATEWAY_IP: \"$ed_public_ingress_external_ip\"" >> global-values.yaml
else
  echo "ED Public Ingress IP not found."
fi

# ED private Loadbalancer IP
ed_private_ingress_external_ip=$(kubectl -n dev get service nginx-private-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Check if the external IP is available
if [[ -n $ed_private_ingress_external_ip ]]; then
  echo "ED Private Ingress IP: $ed_private_ingress_external_ip"
  echo "nginx_ed_private_ingress_ip: \"$ed_private_ingress_external_ip\"" >> global-values.yaml
else
  echo "ED Private Ingress IP not found."
fi

  while IFS=',' read -r chart_name chart_repo; do
    # Check if the chart repository URL is empty
    if [ -z "$chart_repo" ]; then
      echo "Error: Repository URL not found for $chart_name in cokreat-charts.csv"
      exit 1
    fi

      if ! helm upgrade --install "$chart_name" "$chart_repo" -n "$namespace" -f global-values.yaml -f cokreat-sample-values.yml --kubeconfig "$kubeconfig_file" ; then
        echo -e "\e[91mError installing $chart_name\e[0m"
     #   exit 1
     fi
      echo -e "\e[92m$chart_name is installed successfully\e[0m"
    # fi
  done < cokreat-charts.csv
  sleep 240
  PUBLIC_IP=$(kubectl get svc -n dev nginx-public-ingress --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
  echo Public IP of $PUBLIC_IP
  exit 1
neo4j=$(kubectl get pods -l app=neo4j -n dock -o jsonpath='{.items[0].metadata.name}')
kubectl -n dock exec -it $neo4j -c neo4j -- bash -c "bin/cypher-shell <<EOF
CREATE CONSTRAINT ON (domain:domain) ASSERT domain.IL_UNIQUE_ID IS UNIQUE;
CREATE INDEX ON :domain(IL_FUNC_OBJECT_TYPE);
CREATE INDEX ON :domain(IL_SYS_NODE_TYPE);
EOF"  
}

postscript() {

neo4j=$(kubectl get pods -l app=neo4j -n dock -o jsonpath='{.items[0].metadata.name}')
kubectl -n dock exec -it $neo4j -c neo4j -- bash -c "bin/cypher-shell <<EOF
CREATE CONSTRAINT ON (domain:domain) ASSERT domain.IL_UNIQUE_ID IS UNIQUE;
CREATE INDEX ON :domain(IL_FUNC_OBJECT_TYPE);
CREATE INDEX ON :domain(IL_SYS_NODE_TYPE);
EOF"

## Update Neo4J Definition ##
## It is expected to have the definition directory kept in the same folder. Download the definitions
learningpod=`kubectl get pods --selector=app=learning -n dock | awk '{if(NR==2) print $1}'`
kubectl port-forward $learningpod 8085:8080 -n dock &
sleep 5
for f in neo4j-definitions/*;
do
  echo "Updating $f ..."
  curl -X POST -H "Content-Type: application/json" -H "user-id: system" -d @$f  http://localhost:8085/learning-service/taxonomy/domain/definition
done

LOGS1=$(kubectl logs -l job-name=onboardconsumer -n dock --tail=10000)
# Extract the JWT token from the logs
TOKEN_LINE1=$(echo "$LOGS1" | grep "JWT token for api-admin is")
# Use awk to extract the token from the line
TOKEN1=$(echo "$TOKEN_LINE1" | awk -F' : ' '{print $2}')
echo "dock_api_auth_token: \"$TOKEN1\"" >> global-values.yaml

    # Loop through each line in the CSV file
        while IFS=',' read -r chart_name chart_repo; do
            # Check if the chart repository URL is empty
            if [ -z "$chart_repo" ]; then
                echo "Error: Repository URL not found for $chart_name in postscript.csv"
                exit 1
            fi
            if ! helm upgrade --install "$chart_name" "$chart_repo" -n "$namespace" -f global-values.yaml --kubeconfig "$kubeconfig_file" ; then
                echo -e "\e[91mError installing $chart_name\e[0m"
                # exit 1
            fi
            echo -e "\e[92m$chart_name is installed successfully\e[0m"
            # fi
        done < postscript.csv
}

# Parse the command-line arguments
case "$2" in
  cokreat)
    cokreat
    ;;
  postscript)
    postscript "$2"
    ;;  
  *)
    echo "Unknown command: $1"
    echo "Usage: $0 [kubeconfig_file] [-i] [cokreat | postscript] "
    exit 1
    ;;
esac