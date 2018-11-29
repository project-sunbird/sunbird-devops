#!/bin/bash

today=$(date +%d-%b-%y-%a)

aws_app_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=app-$release-$today" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
app_instance_id=$(echo $aws_app_instance | awk '{print $1}')

aws_db_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=db-$release-$today" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
db_instance_id=$(echo $aws_db_instance | awk '{print $1}')

echo -e "Removing application server: $app_instance_id"
echo -e "Removing database server: $db_instance_id"
echo -e "Waiting for servers to terminate..."
sleep 30

aws ec2 terminate-instances --instance-ids $app_instance_id $db_instance_id
