#!/bin/sh
# Build script
# set -o errexit
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(./images/cassandra_jmx_exporter/metadata.sh)

org=$(e "${m}" "org")
name=$(e "${m}" "name")
version=$(e "${m}" "version")

docker build -f ./images/cassandra_jmx_exporter/Dockerfile -t ${org}/${name}:${version} .
