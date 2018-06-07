#!/bin/bash
# Build script
# set -o errexit

cd sunbird-portal/src/app/client
pwd
echo ==================
printenv
echo ==================
source ~/.nvm/nvm.sh
nvm use 8
npm install
npm run build-cdn -- --deployUrl $1
