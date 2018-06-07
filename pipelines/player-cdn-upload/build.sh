#!/bin/bash
# Build script
# set -o errexit

cd sunbird-portal/src/app/client
pwd
echo ==================
printenv
echo ==================
source ~/.nvm/nvm.sh
nvm install 8.11
nvm use 8
chmod -R 777 /home/ops/.npm
whoami
npm install
npm run build-cdn -- --deployUrl $1
