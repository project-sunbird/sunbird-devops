#!/bin/bash
# How to run
# docker run --rm -v$(pwd):/work -v $(pwd)/backup.sh:/work/backup.sh rjshrjndrn/wizzy /work/backup.sh https://grafna/url password
url=$1
password=$2
script=$(echo $0)
cd $(dirname "$script")
echo Backing up grafafna in $(dirname "$script")
wizzy set grafana url $url
wizzy set grafana username admin
wizzy set grafana password $password
wizzy import dashboards

