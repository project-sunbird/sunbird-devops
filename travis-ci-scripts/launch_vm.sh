#!/bin/bash
config_file=$TRAVIS_BUILD_DIR/deploy/config
#aws ec2 run-instances --launch-template LaunchTemplateName=travis-ci-app
#aws ec2 run-instances --launch-template LaunchTemplateName=travis-ci-db
aws ec2 run-instances --image-id ami-0c510557369b14896 --instance-type t2.large --key-name adoption-keshav --subnet-id  subnet-0241076a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=travis-app-$TRAVIS_BUILD_NUMBER-$release}]"
aws ec2 run-instances --image-id ami-0c510557369b14896 --instance-type t2.large --key-name adoption-keshav --subnet-id  subnet-0241076a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=travis-db-$TRAVIS_BUILD_NUMBER-$release}]"
echo "Wait for app and db instances to launch"
sleep 150

aws_app_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=travis-app-$TRAVIS_BUILD_NUMBER-$release" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
app_instance_id=$(echo $aws_app_instance | awk '{print $1}')
app_private_ip=$(echo $aws_app_instance | awk '{print $2}')
app_public_ip=$(echo $aws_app_instance | awk '{print $3}')

aws_db_instance=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  "Name=tag:Name,Values=travis-db-$TRAVIS_BUILD_NUMBER-$release" --query "Reservations[*].Instances[*].{PrivateIP: PrivateIpAddress, PublicIP: PublicIpAddress, InstanceId: InstanceId}")
db_instance_id=$(echo $aws_db_instance | awk '{print $1}')
db_private_ip=$(echo $aws_db_instance | awk '{print $2}')
db_public_ip=$(echo $aws_db_instance | awk '{print $3}')

echo "App instance id: $app_instance_id"
echo "App private ip: $app_private_ip"
echo "App public ip: $app_public_ip"

echo "DB instance id: $db_instance_id"
echo "DB private ip: $db_private_ip"
echo "DB public ip: $db_public_ip"

sed -i "s/application_host:/application_host: $app_private_ip/g" $config_file
sed -i "s/dns_name:/dns_name: $app_public_ip/g" $config_file
sed -i "s/database_host:/database_host: $db_private_ip/g" $config_file
