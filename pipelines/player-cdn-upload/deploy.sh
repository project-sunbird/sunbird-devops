#!/bin/sh
# Build script
# set -o errexit
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(./src/app/metadata.sh)

org=$(e "${m}" "org")
name=$(e "${m}" "name")
version=$(e "${m}" "version")

artifactLabel=${ARTIFACT_LABEL:-bronze}
env=${ENV:-null}

echo "artifactLabel:  ${artifactLabel}"
echo "env:            ${env}"
echo "org:            ${org}"
echo "name:           ${name}"
echo "version:        ${version}"

ansible-playbook --version
ansible-playbook -i ansible/inventory/dev ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${org} image_name=${name} image_tag=${version}-${artifactLabel}" --vault-password-file /run/secrets/vault-pass
