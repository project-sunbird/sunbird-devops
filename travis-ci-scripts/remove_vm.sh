#!/bin/bash
aws_app_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=travis-app-$TRAVIS_BUILD_NUMBER-$release" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
app_instance_id=$(echo $aws_app_instance | awk '{print $1}')

aws_db_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=travis-db-$TRAVIS_BUILD_NUMBER-$release" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
db_instance_id=$(echo $aws_db_instance | awk '{print $1}')

echo "Removing app instance with id: $app_instance_id"

echo "Removing DB instance with id: $db_instance_id"

echo "Wait before terminating instance"
sleep 60

aws ec2 terminate-instances --instance-ids $app_instance_id $db_instance_id
