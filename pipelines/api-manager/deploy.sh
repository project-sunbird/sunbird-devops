#!/bin/sh
# Build script
# set -o errexit
set -e
e () {
    echo $( echo ${1} | jq ".${2}" | sed 's/\"//g')
}
m=$(cat $METADATA_FILE)

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
ansible-playbook -i sunbird-devops/ansible/inventories/$ENV sunbird-devops/ansible/deploy.yml --tags "stack-api-manager" --extra-vars "hub_org=${org} echo_server_image_name=${name} echo_server_image_tag=${version}-${artifactLabel}" --vault-password-file /run/secrets/vault-pass
