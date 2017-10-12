#!/bin/sh
# Build script
# set -o errexit
set -e
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(./images/keycloak/metadata.sh)

org=$(e "${m}" "org")
name=$(e "${m}" "name")
version=$(e "${m}" "version")

docker build -f ./images/keycloak/Dockerfile -t ${org}/${name}:${version}-bronze .