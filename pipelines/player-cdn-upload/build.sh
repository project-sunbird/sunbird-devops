#!/bin/bash
# Build script
# set -o errexit

apk add --no-cache git
npm install -g gulp
cd sunbird-portal/src/app
gulp download:editors
cd client
pwd
echo ==================
printenv
echo ==================
source ~/.nvm/nvm.sh
nvm install 8.11
nvm use 8
chmod -R 777 /home/ops/.npm
whoami
npm cache clean
npm install
npm run build-cdn -- --deployUrl $1
mv ../dist/index.html ../dist/index.ejs
