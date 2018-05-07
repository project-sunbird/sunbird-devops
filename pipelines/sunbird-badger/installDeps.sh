#!/bin/sh
# Build script
# set -o errexit
sudo apk add --no-cache gcc git libffi-dev musl-dev openssl-dev perl py-pip python python-dev sshpass
apk -v --update --no-cache add jq
# apk -v --no-cache add ansible=2.3.0.0-r1
pip install ansible==2.4.1
