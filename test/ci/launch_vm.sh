#!/bin/bash

aws --version
aws configure set aws_access_key_id $keyid
aws configure set aws_secret_access_key $key
aws configure set region ap-south-1
aws configure set output text
echo -e "aws cli configured.."


aws ec2 run-instances --image-id ami-0c510557369b14896 --instance-type t2.large --key-name adoption-keshav --subnet-id  subnet-0241076a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=circle-app-$CIRCLE_BUILD_NUM}]" 1> /dev/null
aws ec2 run-instances --image-id ami-0c510557369b14896 --instance-type t2.large --key-name adoption-keshav --subnet-id  subnet-0241076a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=circle-db-$CIRCLE_BUILD_NUM}]" 1> /dev/null
echo -e "Waiting for servers to launch..."
sleep 180


