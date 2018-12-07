#!/bin/bash

build_info=./tests/ci/build_info

aws --version
aws configure set aws_access_key_id $keyid
aws configure set aws_secret_access_key $key
aws configure set region ap-south-1
aws configure set output text
echo -e "aws cli configured.."

today=$(date +%d-%b-%y-%a)

aws ec2 run-instances --image-id ami-0c510557369b14896 --instance-type t2.large --key-name ci-build --subnet-id  subnet-0241076a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=app-$release-$today}]" 1> /dev/null
aws ec2 run-instances --image-id ami-0c510557369b14896 --instance-type t2.large --key-name ci-build --subnet-id  subnet-0241076a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=db-$release-$today}]" 1> /dev/null
echo -e "Waiting for servers to launch..."
sleep 180

aws_app_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=app-$release-$today" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
app_instance_id=$(echo -e $aws_app_instance | awk '{print $1}')
app_private_ip=$(echo -e $aws_app_instance | awk '{print $2}')
app_public_ip=$(echo -e $aws_app_instance | awk '{print $3}')

aws_db_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=db-$release-$today" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
db_instance_id=$(echo -e $aws_db_instance | awk '{print $1}')
db_private_ip=$(echo -e $aws_db_instance | awk '{print $2}')
db_public_ip=$(echo -e $aws_db_instance | awk '{print $3}')

cat > $build_info << EOF
ansible_private_key_path: $ansible_private_key_path
app_address_space: $app_address_space
backup_storage_key: $backup_storage_key
badger_admin_email: $badger_admin_email
badger_admin_password: $badger_admin_password
database_password: $database_password
ekstep_api_base_url: $ekstep_api_base_url
ekstep_api_key: $ekstep_api_key
ekstep_proxy_base_url: $ekstep_proxy_base_url
email_password: $email_password
env: $env
from_address: $from_address
implementation_name: $implementation_name
keycloak_admin_password: $keycloak_admin_password
proto: $proto
ssh_ansible_user: $ssh_ansible_user
sso_password: $sso_password
sunbird_azure_storage_account: $sunbird_azure_storage_account
sunbird_azure_storage_key: $sunbird_azure_storage_key
sunbird_custodian_tenant_channel: $sunbird_custodian_tenant_channel
sunbird_custodian_tenant_description: $sunbird_custodian_tenant_description
sunbird_custodian_tenant_name: $sunbird_custodian_tenant_name
sunbird_default_channel: $sunbird_default_channel
sunbird_image_storage_url: $sunbird_image_storage_url
sunbird_root_user_email: $sunbird_root_user_email
sunbird_root_user_firstname: $sunbird_root_user_firstname
sunbird_root_user_lastname: $sunbird_root_user_lastname
sunbird_root_user_password: $sunbird_root_user_password
sunbird_root_user_phone: $sunbird_root_user_phone
sunbird_root_user_username: $sunbird_root_user_username
to_address: $to_address
trampoline_secret: $trampoline_secret
application_host: $app_private_ip
dns_name: $app_public_ip
database_host: $db_private_ip
EOF
