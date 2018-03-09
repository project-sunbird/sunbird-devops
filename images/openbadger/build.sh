#!/bin/sh
# Build script
# set -o errexit
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(./images/openbadger/metadata.sh)

org=$(e "${m}" "org")
name=$(e "${m}" "name")
version=$(e "${m}" "version")

docker build -f ./images/openbadger/Dockerfile -t ${org}/${name}:${version}-bronze .
