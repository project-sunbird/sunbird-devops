#!/bin/sh
# Build script
# set -o errexit
set -e
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(./images/keycloak/metadata.sh)

org=$(e "${m}" "org")
hubuser=$(e "${m}" "hubuser")
name=$(e "${m}" "name")
version=$(e "${m}" "version")
artifactLabel=${ARTIFACT_LABEL:-bronze}

docker login -u "purplesunbird" -p`cat /home/ops/vault_pass`
docker push ${org}/${name}:${version}-${artifactLabel}
docker logout

