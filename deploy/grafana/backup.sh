#!/bin/bash
# How to run
# docker run --rm -v /etc/passwd:/etc/passwd -u $(id -u):$(id -g) -v$(pwd):/work -v $(pwd)/backup.sh:/work/backup.sh rjshrjndrn/wizzy /work/backup.sh https://grafna/url admin password <import or export>
url=$1
username=$2
password=$3
mode=${4:-import}
item=${5:-dashboards}
script=$(echo $0)
cd $(dirname "$script")
echo ${mode}ing grafafna in $(dirname "$script")
wizzy init
wizzy set grafana url $url
wizzy set grafana username $username
wizzy set grafana password $password
wizzy $mode $item
