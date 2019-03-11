#!/bin/sh
# Build script
# set -o errexit

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
echo "ANSIBLE_PATH:   $ANSIBLE_PATH"

ansible-playbook --version
ansible-playbook -i ansible/inventory/$ENV ansible/deploy.yml --tags "stack-sunbird" --extra-vars "hub_org=${org} image_name=${name} image_tag=${version}-${artifactLabel} service_name=telemetry-service deploy_telemetry=True" --vault-password-file /run/secrets/vault-pass
