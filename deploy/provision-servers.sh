#!/usr/bin/env bash
# Provision servers
set -eu -o pipefail
set -x

echo "${DEPLOYMENT_JSON_PATH:?You must set DEPLOYMENT_JSON_PATH}"
AZURE_DEPLOY_SCRIPT=`pwd`/deploy-azure.sh

if [ -d acs-engine ]; then 
    (cd acs-engine && git pull); 
else 
    echo "cloning"
    git clone $repourl;
fi
cd acs-engine
rm -rf ./scripts/deploy-azure.sh

docker build --pull -t acs-engine .

docker run -it --rm \
	--privileged \
	--security-opt seccomp:unconfined \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v `pwd`:/gopath/src/github.com/Azure/acs-engine \
    -v ${DEPLOYMENT_JSON_PATH}:/gopath/src/github.com/Azure/acs-engine/deployments/deployment \
    -v ${AZURE_DEPLOY_SCRIPT}:/gopath/src/github.com/Azure/acs-engine/scripts/deploy-azure.sh \
	-v ~/.azure:/root/.azure \
	-w /gopath/src/github.com/Azure/acs-engine \
		acs-engine /bin/bash ./scripts/deploy-azure.sh

chown -R "$(logname):$(id -gn $(logname))" . ~/.azure
