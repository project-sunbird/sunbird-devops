#!/bin/bash
# How to run
# docker run --rm -v /etc/passwd:/etc/passwd -u $(id -u):$(id -g) -v$(pwd):/work -v $(pwd)/backup.sh:/work/backup.sh rjshrjndrn/wizzy /work/backup.sh https://grafna/url admin password
url=$1
username=$2
password=$3
script=$(echo $0)
cd $(dirname "$script")
echo Backing up grafafna in $(dirname "$script")
wizzy set grafana url $url
wizzy set grafana username $username
wizzy set grafana password $password
wizzy import dashboards
