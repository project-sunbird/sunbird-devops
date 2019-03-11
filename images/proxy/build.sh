#!/bin/sh
# Build script
# set -o errexit
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(./images/proxy/metadata.sh)

org=$(e "${m}" "org")
name=$(e "${m}" "name")
version=$(e "${m}" "version")

docker build -f ./images/proxy/Dockerfile -t ${org}/${name}:${version}-bronze .
