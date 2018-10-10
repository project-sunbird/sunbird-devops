#!/bin/bash
aws --version
aws configure set aws_access_key_id $keyid
aws configure set aws_secret_access_key $key
aws configure set region ap-south-1
aws configure set output text
