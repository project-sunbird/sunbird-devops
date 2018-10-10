#!/bin/bash
config_file=./deploy/config
aws ec2 run-instances --image-id ami-0c510557369b14896 --instance-type t2.large --key-name adoption-keshav --subnet-id  subnet-0241076a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=circle-app-$CIRCLE_BUILD_NUM-$release}]" 1> /dev/null
aws ec2 run-instances --image-id ami-0c510557369b14896 --instance-type t2.large --key-name adoption-keshav --subnet-id  subnet-0241076a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=circle-db-$CIRCLE_BUILD_NUM-$release}]" 1> /dev/null
echo -e "Waiting for servers to launch..."
sleep 150

aws_app_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=circle-app-$CIRCLE_BUILD_NUM-$release" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
app_instance_id=$(echo -e $aws_app_instance | awk '{print $1}')
app_private_ip=$(echo -e $aws_app_instance | awk '{print $2}')
app_public_ip=$(echo -e $aws_app_instance | awk '{print $3}')

aws_db_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=circle-db-$CIRCLE_BUILD_NUM-$release" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
db_instance_id=$(echo -e $aws_db_instance | awk '{print $1}')
db_private_ip=$(echo -e $aws_db_instance | awk '{print $2}')
db_public_ip=$(echo -e $aws_db_instance | awk '{print $3}')

echo -e "Application server details:"
echo -e "Instance ID: $app_instance_id\nPrivate IP: $app_private_ip\nPublic IP: $app_public_ip"

echo -e "\nDatabase server details"
echo -e "Instance ID: $db_instance_id\nPrivate IP: $db_private_ip\nPublic IP: $db_public_ip"

sed -i "s/application_host:/application_host: $app_private_ip/g" $config_file
sed -i "s/dns_name:/dns_name: $app_public_ip/g" $config_file
sed -i "s/database_host:/database_host: $db_private_ip/g" $config_file
