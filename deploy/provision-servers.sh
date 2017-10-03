#!/usr/bin/env bash
# Provision servers
set -eu -o pipefail
set -x

echo "${APP_DEPLOYMENT_JSON_PATH:?You must set APP_DEPLOYMENT_JSON_PATH}"
if [ "${DB_DEPLOYMENT:-true}" == "true" ]; then
	echo "${DB_DEPLOYMENT_JSON_PATH:?You must set DB_DEPLOYMENT_JSON_PATH}"
else
	DB_DEPLOYMENT_JSON_PATH=/dev/null
fi

AZURE_DEPLOY_SCRIPT=`pwd`/deploy-azure.sh
repourl=https://github.com/Azure/acs-engine.git
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
if [ -d acs-engine ]; then 
    (cd acs-engine && git pull); 
else 
    echo "cloning"
    git clone $repourl;
fi
cd acs-engine
rm -rf ./scripts/deploy-azure.sh
rm -rf ./deployments

docker build --pull -t acs-engine .
docker version

ls -al $APP_DEPLOYMENT_JSON_PATH
ls -al $DB_DEPLOYMENT_JSON_PATH
ls -al $AZURE_DEPLOY_SCRIPT

docker run \
	--privileged \
	--security-opt seccomp:unconfined \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v `pwd`:/gopath/src/github.com/Azure/acs-engine \
	-v ${APP_DEPLOYMENT_JSON_PATH}:/gopath/src/github.com/Azure/acs-engine/deployments/deployment/app \
	-v ${DB_DEPLOYMENT_JSON_PATH}:/gopath/src/github.com/Azure/acs-engine/deployments/deployment/db \
	-v ${AZURE_DEPLOY_SCRIPT}:/gopath/src/github.com/Azure/acs-engine/scripts/deploy-azure.sh \
	-v ~/.azure:/root/.azure \
	-w /gopath/src/github.com/Azure/acs-engine \
	--rm \
	acs-engine /bin/bash ./scripts/deploy-azure.sh

chown -R "$(logname):$(id -gn $(logname))" . ~/.azure
