#!/bin/bash
# Build script
# set -o errexit

deployUrl=$1

apk add --no-cache git python make g++ jq
cd sunbird-portal/src/app
version=$(jq '.version' package.json | sed 's/\"//g')
build_number=$(jq '.buildNumber' package.json | sed 's/\"//g')
npm install
./node_modules/.bin/gulp download:editors
cd client
npm install
npm run build-cdn -- --deployUrl ${deployUrl}
# package.json in app folder
mv ../dist/index.html ../dist/index_${version}.${build_number}.ejs
