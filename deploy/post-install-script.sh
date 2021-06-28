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

echo "User provided inputs"
echo "proto: $proto"
echo "domain_name: $domain_name"
echo "core_vault_sunbird_api_auth_token: $core_vault_sunbird_api_auth_token"
echo "private_ingressgateway_ip: $private_ingressgateway_ip"
echo "learningservice_ip: $learningservice_ip"
echo "core_vault_sunbird_sso_client_secret: $core_vault_sunbird_sso_client_secret"
echo "core_vault_sunbird_google_captcha_site_key_portal: $core_vault_sunbird_google_captcha_site_key_portal"
echo "sunbird_azure_public_storage_account_name: $sunbird_azure_public_storage_account_name"
echo "cassandra-1: $cassandra"