#!/bin/bash

set -euo pipefail

proto=$1
domain_name=$2
core_vault_sunbird_api_auth_token=$3
private_ingressgateway_ip=$4
learningservice_ip=$5
core_vault_sunbird_sso_client_secret=$6
core_vault_sunbird_google_captcha_site_key_portal=$7
sunbird_azure_public_storage_account_name=$8
cassandra=$9

cassandra_forms(){  
  echo "OK"
}

bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\e[0;32m${bold}User provided inputs ${normal}"
echo -e "\e[0;90m${bold}proto: $proto ${normal}"
echo -e "\e[0;90m${bold}domain_name: $domain_name ${normal}"
echo -e "\e[0;90m${bold}core_vault_sunbird_api_auth_token: $core_vault_sunbird_api_auth_token ${normal}"
echo -e "\e[0;90m${bold}private_ingressgateway_ip: $private_ingressgateway_ip ${normal}"
echo -e "\e[0;90m${bold}learningservice_ip: $learningservice_ip ${normal}"
echo -e "\e[0;90m${bold}core_vault_sunbird_sso_client_secret: $core_vault_sunbird_sso_client_secret ${normal}"
echo -e "\e[0;90m${bold}core_vault_sunbird_google_captcha_site_key_portal: $core_vault_sunbird_google_captcha_site_key_portal ${normal}"
echo -e "\e[0;90m${bold}sunbird_azure_public_storage_account_name: $sunbird_azure_public_storage_account_name ${normal}"
echo -e "\e[0;90m${bold}cassandra-1: $cassandra"