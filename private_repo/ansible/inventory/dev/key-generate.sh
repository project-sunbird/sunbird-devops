#!/bin/bash
set -euo pipefail
read -s -p 'Enter the ansible vault password (redacted): ' vault_pass
echo
read -s -p 'Re-enter the ansible vault password (redacted): ' confirm_vault_pass
echo
if [[ $vault_pass == $confirm_vault_pass ]]
then
  echo "$vault_pass" > temp_vault_pass
  mkdir -p Core/keys && cd Core/keys
  for i in {1..10}; do openssl genrsa -out mobile_devicev2_c$i 2048 && openssl pkcs8 -topk8 -inform PEM -in mobile_devicev2_c$i -out mobile_devicev2_key$i -nocrypt && rm -rf mobile_devicev2_c$i ; done
  for i in {1..10}; do openssl genrsa -out accessv1_c$i 2048 && openssl pkcs8 -topk8 -inform PEM -in accessv1_c$i -out accessv1_key$i -nocrypt && rm -rf accessv1_c$i ; done
  for i in {1..10}; do openssl genrsa -out desktop_devicev2_c$i 2048 && openssl pkcs8 -topk8 -inform PEM -in desktop_devicev2_c$i -out desktop_devicev2_key$i -nocrypt && rm -rf desktop_devicev2_c$i ; done
  for i in {1..10}; do openssl genrsa -out portal_anonymous_c$i 2048 && openssl pkcs8 -topk8 -inform PEM -in portal_anonymous_c$i -out portal_anonymous_key$i -nocrypt && rm -rf portal_anonymous_c$i ; done
  for i in {1..10}; do openssl genrsa -out portal_loggedin_c$i 2048 && openssl pkcs8 -topk8 -inform PEM -in portal_loggedin_c$i -out portal_loggedin_key$i -nocrypt && rm -rf portal_loggedin_c$i ; done
  while read -r line; do ansible-vault encrypt $line --vault-password-file ../../temp_vault_pass; done <<< $(ls)
  cd ../.. && rm temp_vault_pass
  echo "OK"
else
  echo "Vault passwords dont match"
fi