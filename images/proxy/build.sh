#!/bin/sh
# Build script
# set -o errexit
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(./images/proxy/metadata.sh)

author=$(e "${m}" "author")
name=$(e "${m}" "name")
version=$(e "${m}" "version")

docker build -f ./Dockerfile -t ${author}/${name}:${version}-bronze .
