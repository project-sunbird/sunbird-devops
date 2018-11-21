#!/bin/bash

config_file=./deploy/config.yml.sample
email_file=./test/ci/send_email.py

aws_app_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=circle-app-$CIRCLE_BUILD_NUM" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
app_instance_id=$(echo -e $aws_app_instance | awk '{print $1}')
app_private_ip=$(echo -e $aws_app_instance | awk '{print $2}')
app_public_ip=$(echo -e $aws_app_instance | awk '{print $3}')

aws_db_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=circle-db-$CIRCLE_BUILD_NUM" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
db_instance_id=$(echo -e $aws_db_instance | awk '{print $1}')
db_private_ip=$(echo -e $aws_db_instance | awk '{print $2}')
db_public_ip=$(echo -e $aws_db_instance | awk '{print $3}')

echo -e "Application server details:"
echo -e "Instance ID: $app_instance_id\nPrivate IP: $app_private_ip\nPublic IP: $app_public_ip"
echo -e "\nDatabase server details"
echo -e "Instance ID: $db_instance_id\nPrivate IP: $db_private_ip\nPublic IP: $db_public_ip"

sed -i "s|application_host:.*#|application_host: $app_private_ip                    #|g" $config_file
sed -i "s|dns_name:.*#|dns_name: $app_public_ip                    #|g" $config_file
sed -i "s|database_host:.*#|database_host: $db_private_ip                    #|g" $config_file
sed -i "s|env:.*#|env: $env                    #|g" $config_file
sed -i "s|implementation_name:.*#|implementation_name: $implementation_name                    #|g" $config_file
sed -i "s|ssh_ansible_user:.*#|ssh_ansible_user: $ssh_ansible_user                    #|g" $config_file
sed -i "s|ansible_private_key_path:.*#|ansible_private_key_path: $ansible_private_key_path                    #|g" $config_file
sed -i "s|app_address_space:.*#|app_address_space: $app_address_space                    #|g" $config_file
sed -i "s|proto:.*#|proto: $proto                    #|g" $config_file
sed -i "s|database_password:.*#|database_password: $database_password                    #|g" $config_file
sed -i "s|keycloak_admin_password:.*#|keycloak_admin_password: $keycloak_admin_password                    #|g" $config_file
sed -i "s|sso_password:.*#|sso_password: $sso_password                    #|g" $config_file
sed -i "s|trampoline_secret:.*#|trampoline_secret: $trampoline_secret                    #|g" $config_file
sed -i "s|backup_storage_key:.*#|backup_storage_key: $backup_storage_key                    #|g" $config_file
sed -i "s|badger_admin_password:.*#|badger_admin_password: $badger_admin_password                    #|g" $config_file
sed -i "s|badger_admin_email:.*#|badger_admin_email: $badger_admin_email                    #|g" $config_file
sed -i "s|ekstep_api_base_url:.*#|ekstep_api_base_url: https://api-qa.ekstep.in                    #|g"  $config_file
sed -i "s|ekstep_proxy_base_url:.*#|ekstep_proxy_base_url: https://qa.ekstep.in                    #|g"  $config_file
sed -i "s|ekstep_api_key:.*#|ekstep_api_key: $ekstep_api_key                    #|g" $config_file
sed -i "s|sunbird_image_storage_url:.*#|sunbird_image_storage_url: $sunbird_image_storage_url                    #|g" $config_file
sed -i "s|sunbird_azure_storage_key:.*#|sunbird_azure_storage_key: $sunbird_azure_storage_key                    #|g" $config_file
sed -i "s|sunbird_azure_storage_account:.*#|sunbird_azure_storage_account: $sunbird_azure_storage_account                    #|g" $config_file
sed -i "s|sunbird_custodian_tenant_name:.*#|sunbird_custodian_tenant_name: $sunbird_custodian_tenant_name                    #|g" $config_file
sed -i "s|sunbird_custodian_tenant_description:.*#|sunbird_custodian_tenant_description: $sunbird_custodian_tenant_description                    #|g" $config_file
sed -i "s|sunbird_custodian_tenant_channel:.*#|sunbird_custodian_tenant_channel: $sunbird_custodian_tenant_channel                    #|g" $config_file
sed -i "s|sunbird_root_user_firstname:.*#|sunbird_root_user_firstname: $sunbird_root_user_firstname                    #|g" $config_file
sed -i "s|sunbird_root_user_lastname:.*#|sunbird_root_user_lastname: $sunbird_root_user_lastname                    #|g" $config_file
sed -i "s|sunbird_root_user_username:.*#|sunbird_root_user_username: $sunbird_root_user_username                    #|g" $config_file
sed -i "s|sunbird_root_user_password:.*#|sunbird_root_user_password: $sunbird_root_user_password                    #|g" $config_file
sed -i "s|sunbird_root_user_email:.*#|sunbird_root_user_email: $sunbird_root_user_email                    #|g" $config_file
sed -i "s|sunbird_root_user_phone:.*#|sunbird_root_user_phone: $sunbird_root_user_phone                    #|g" $config_file
sed -i "s|sunbird_default_channel:.*#|sunbird_default_channel: $sunbird_default_channel                    #|g"  $config_file
echo -e "Config file updated..."

sed -i "s|from_address|$from_address|g" $email_file
sed -i "s|to_address|$to_address|g" $email_file
sed -i "s|email_password|$email_password|g" $email_file
echo -e "Email file updated..."

