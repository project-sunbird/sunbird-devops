#!/bin/sh
# Build script
# set -o errexit
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(cat $METADATA_FILE)

org=$(e "${m}" "org")
hubuser=$(e "${m}" "hubuser")
name=$(e "${m}" "name")
version=$(e "${m}" "version")

artifactLabel=${ARTIFACT_LABEL:-silver}

docker pull ${org}/${name}:${version}-${PREVIOUS_LABEL}
docker image tag ${org}/${name}:${version}-${PREVIOUS_LABEL} ${org}/${name}:${version}-${artifactLabel}

docker login -u "${hubuser}" -p`cat /run/secrets/hub-pass`
docker push ${org}/${name}:${version}-${artifactLabel}
docker logout
