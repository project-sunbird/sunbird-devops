#!/bin/bash
# Set the namespace for the Helm charts
namespace="dev"

# Check if kubeconfig file is provided as argument
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [kubeconfig_file] [ed-install | collection | postscript]"
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

# Check if the ed-charts.csv file exists
if [ ! -f "ed-charts.csv" ]; then
  echo "Error: ed-charts.csv file not found"
  exit 1
fi

ed-install() {
figlet -f slant "Sunbird Ed Installation"
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

echo "cloud_private_storage_secret: $AccountKey" >> global-values.yaml
echo "cloud_storage_secret: $AccountKey" >> global-values.yaml
echo "sunbird_azure_account_key: $AccountKey" >> global-values.yaml

NginxPrvateIP=$(grep "nginx_private_ingress_ip" global-values.yaml | awk -F ":" '{if($1=="nginx_private_ingress_ip") print $2}' | awk '{print $1}' | sed 's/^.\(.*\).$/\1/')
echo "sunbird_user_service_base_url: \"http://$NginxPrvateIP/learner\"" >> global-values.yaml
echo "sunbird_lms_base_url: \"http://$NginxPrvateIP/api\"" >> global-values.yaml

DomainName=$(grep "domain" global-values.yaml | awk -F ":" '{if($1=="domain") print $2}' | awk '{print $1}' | sed 's/^.\(.*\).$/\1/')
echo "sunbird_sso_url: \"http://$DomainName/auth/\"" >> global-values.yaml

### Trigger Lern Installer 
./install-lern.sh $kubeconfig_file 
sleep 240
### Trigger Observ Installer 
./install-obsrv.sh $kubeconfig_file
sleep 120
### Trigger InQuiry Installer 
./install-inquiry.sh $kubeconfig_file
sleep 120
### Trigger Knowlg Installer
./install-knowlg.sh $kubeconfig_file
### Upload the plugins and editors ####
# ./upload-plugins.sh 

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
      if ! helm upgrade --install "$chart_name" "$chart_repo" -n "$namespace" -f global-values.yaml -f ed-sample-values.yml --kubeconfig "$kubeconfig_file" ; then
        echo -e "\e[91mError installing $chart_name\e[0m"
     #   exit 1
     fi
      echo -e "\e[92m$chart_name is installed successfully\e[0m"
    # fi
  done < ed-charts.csv
  sleep 240
  PUBLIC_IP=$(kubectl get svc -n dev nginx-public-ingress --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
  echo Public IP of $PUBLIC_IP
  exit 1
}

postscript() {
# Get the job logs and search for the tokens for onboardconsumer
LOGS=$(kubectl logs -l job-name=onboardconsumer -n dev --tail=10000 | grep -E "JWT token for api-admin is")
# Extract the JWT token from the logs
TOKEN=$(echo $LOGS | grep -oP "(?<=: ).*")
# Print the tokens
echo "JWT token for api-admin:"
echo "$TOKEN"

LOGS1=$(kubectl logs -l job-name=onboardconsumer -n dev --tail=10000| grep -E "JWT token for portal_loggedin_register is")
# Extract the JWT token from the logs
LOGGEDIN_TOKEN=$(echo $LOGS1 | grep -oP "(?<=: ).*")
# Print the tokens
echo "JWT token for portal_loggedin_register:"
echo "$LOGGEDIN_TOKEN"

LOGS2=$(kubectl logs -l job-name=onboardconsumer -n dev --tail=10000 | grep -E "JWT token for portal_anonymous_register is")
# Extract the JWT token from the logs
ANONYMOUS_TOKEN=$(echo $LOGS2 | grep -oP "(?<=: ).*")
# Print the tokens
echo "JWT token for portal_anonymous_register:"
echo "$ANONYMOUS_TOKEN"

LOGS3=$(kubectl logs -l job-name=onboardconsumer -n dev --tail=10000 | grep -E "JWT token for portal_loggedin is")
# Extract the JWT token from the logs
PORTAL_LOGGEDIN_TOKEN=$(echo $LOGS3 | grep -oP "(?<=: ).*")
# Print the tokens
echo "JWT token for portal_loggedin:"
echo "$PORTAL_LOGGEDIN_TOKEN"

LOGS4=$(kubectl logs -l job-name=onboardconsumer -n dev --tail=10000 | grep -E "JWT token for portal_anonymous is")
# Extract the JWT token from the logs
PORTAL_ANONYMOUS_TOKEN=$(echo $LOGS4 | grep -oP "(?<=: ).*")
# Print the tokens
echo "JWT token for portal_anonymous:"
echo "$PORTAL_ANONYMOUS_TOKEN"

LOGS5=$(kubectl logs -l job-name=onboardconsumer -n dev --tail=10000 | grep -E "JWT token for adminutil_learner_api_key is")
# Extract the JWT token from the logs
ADMINUTIL_LEARNER_TOKEN=$(echo $LOGS5 | grep -oP "(?<=: ).*")
# Print the tokens
echo "JWT token for adminutil_learner_api_key:"
echo "$ADMINUTIL_LEARNER_TOKEN"

echo "core_vault_sunbird_api_auth_token: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_api_auth_token: \"$TOKEN\"" >> global-values.yaml
echo "ekstep_authorization: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_authorization: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_content_repo_api_key: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_language_service_api_key: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_learner_service_api_key: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_dial_repo_api_key: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_search_service_api_key: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_plugin_repo_api_key: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_data_service_api_key: \"$TOKEN\"" >> global-values.yaml
echo "sunbird_loggedin_register_token: \"$LOGGEDIN_TOKEN\"" >> global-values.yaml
echo "sunbird_anonymous_register_token: \"$ANONYMOUS_TOKEN\"" >> global-values.yaml
echo "sunbird_logged_default_token: \"$PORTAL_LOGGEDIN_TOKEN\"" >> global-values.yaml
echo "sunbird_anonymous_default_token: \"$PORTAL_ANONYMOUS_TOKEN\"" >> global-values.yaml
echo "LEARNER_API_AUTH_KEY: \"$ADMINUTIL_LEARNER_TOKEN\"" >> global-values.yaml

# Add consumer for portal_loggedin
apimanagerpod=$(kubectl get pods --selector=app=apimanager -n dev | awk 'NR==2{print $1}')
kubectl port-forward $apimanagerpod 8001:8001 -n dev &
sleep 5
port_forward_pid=$!
cd keys
curl -XPOST http://localhost:8001/consumers/portal_loggedin/jwt -F "key=portal_loggedin_key1" -F "algorithm=RS256" -F "rsa_public_key=@portal_loggedin_key1"
curl -XPOST http://localhost:8001/consumers/portal_loggedin/jwt -F "key=portal_loggedin_key2" -F "algorithm=RS256" -F "rsa_public_key=@portal_loggedin_key2"
cd -
kill $port_forward_pid

    # Loop through each line in the CSV file
        while IFS=',' read -r chart_name chart_repo; do
            # Check if the chart repository URL is empty
            if [ -z "$chart_repo" ]; then
                echo "Error: Repository URL not found for $chart_name in postscript.csv"
                exit 1
            fi

            # # Check if the chart is already installed
            # if helm list -n "$namespace" | grep -q "$chart_name"; then
            #   echo -e "\e[92m$chart_name is already installed\e[0m"
            # else
            # Install the chart with global variables
            if ! helm upgrade --install "$chart_name" "$chart_repo" -n "$namespace" -f global-values.yaml --kubeconfig "$kubeconfig_file" ; then
                echo -e "\e[91mError installing $chart_name\e[0m"
                # exit 1
            fi
            echo -e "\e[92m$chart_name is installed successfully\e[0m"
            # fi
        done < postscript.csv
}

collection() {
  # Check if NVM is already installed
  if command -v nvm &>/dev/null; then
    echo "NVM is already installed"
  else
    # Install NVM if not present
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    echo "NVM installed"
  fi

  # Install Node.js version 12
  echo "Installing Node.js version 12..."
  nvm install 12
  nvm use 12

  # Check if Newman is already installed
  if command -v newman &>/dev/null; then
    echo "Newman is already installed"
  else
    # Install Newman if not present
    echo "Installing Newman..."
    npm install -g newman
    echo "Newman installed"
  fi

  # Check if files exist
  if [ -f "postman/collection.json" ] && [ -f "postman/environment.json" ]; then
    # Execute Newman command
    echo "Executing Newman command..."
    newman run postman/collection.json -e environment.json
  else
    echo "File not found in the 'postman' folder"
    exit 1
  fi
}

# Parse the command-line arguments
case "$2" in
  ed-install)
    ed-install
    ;;
  postscript)
    postscript "$2"
    ;;  
  collection)
    collection "$3"
    ;;  
  *)
    echo "Unknown command: $1"
    echo "Usage: $0 [kubeconfig_file] [-i] [ed-install |  collection | postscript] "
    exit 1
    ;;
esac