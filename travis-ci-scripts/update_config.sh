#!/bin/bash
config_file=$TRAVIS_BUILD_DIR/deploy/config
sed -i "s/env:/env: $env/g" $config_file
sed -i "s/implementation_name:/implementation_name: $implementation_name/g" $config_file
sed -i "s/ssh_ansible_user:/ssh_ansible_user: $ssh_ansible_user/g" $config_file
sed -i "s#ansible_private_key_path:#ansible_private_key_path: $ansible_private_key_path#g" $config_file
sed -i "s#app_address_space:#app_address_space: $app_address_space#g" $config_file
sed -i "s/proto:/proto: $proto/g" $config_file
sed -i "s/database_password:/database_password: $database_password/g" $config_file
sed -i "s/keycloak_admin_password:/keycloak_admin_password: $keycloak_admin_password/g" $config_file
sed -i "s/sso_password:/sso_password: $sso_password/g" $config_file
sed -i "s/trampoline_secret:/trampoline_secret: $trampoline_secret/g" $config_file
sed -i "s/backup_storage_key:/backup_storage_key: $backup_storage_key/g" $config_file
sed -i "s/badger_admin_password:/badger_admin_password: $badger_admin_password/g" $config_file
sed -i "s/badger_admin_email:/badger_admin_email: $badger_admin_email/g" $config_file
sed -i "s?ekstep_api_base_url:.*#?ekstep_api_base_url: https://api-qa.ekstep.in  #  ?g"  $config_file
sed -i "s?ekstep_proxy_base_url:.*#?ekstep_proxy_base_url: https://qa.ekstep.in  #  ?g"  $config_file
sed -i "s#ekstep_api_key:#ekstep_api_key: $ekstep_api_key#g" $config_file
sed -i "s#sunbird_image_storage_url:#sunbird_image_storage_url: $sunbird_image_storage_url#g" $config_file
sed -i "s#sunbird_azure_storage_key:#sunbird_azure_storage_key: $sunbird_azure_storage_key#g" $config_file
sed -i "s/sunbird_azure_storage_account:/sunbird_azure_storage_account: $sunbird_azure_storage_account/g" $config_file
sed -i "s/sunbird_custodian_tenant_name:/sunbird_custodian_tenant_name: $sunbird_custodian_tenant_name/g" $config_file
sed -i "s/sunbird_custodian_tenant_description:/sunbird_custodian_tenant_description: $sunbird_custodian_tenant_description/g" $config_file
sed -i "s/sunbird_custodian_tenant_channel:/sunbird_custodian_tenant_channel: $sunbird_custodian_tenant_channel/g" $config_file
sed -i "s/sunbird_root_user_firstname:/sunbird_root_user_firstname: $sunbird_root_user_firstname/g" $config_file
sed -i "s/sunbird_root_user_lastname:/sunbird_root_user_lastname: $sunbird_root_user_lastname/g" $config_file
sed -i "s/sunbird_root_user_username:/sunbird_root_user_username: $sunbird_root_user_username/g" $config_file
sed -i "s/sunbird_root_user_password:/sunbird_root_user_password: $sunbird_root_user_password/g" $config_file
sed -i "s/sunbird_root_user_email:/sunbird_root_user_email: $sunbird_root_user_email/g" $config_file
sed -i "s/sunbird_root_user_phone:/sunbird_root_user_phone: $sunbird_root_user_phone/g" $config_file
sed -i "s/sunbird_default_channel:/sunbird_default_channel: $sunbird_default_channel/g"  $config_file
