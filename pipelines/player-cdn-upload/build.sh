#!/bin/bash
# Build script
# set -o errexit

apk add --no-cache git python make g++ jq
cd sunbird-portal/src/app
npm install
./node_modules/.bin/gulp download:editors
cd client
npm install
npm run build-cdn -- --deployUrl $1
# package.json in app folder
version=$(jq '.version' package.json | sed 's/\"//g')
build_number=$(jq '.buildNumber' package.json | sed 's/\"//g')
mv ../dist/index.html ../dist/index_${version}.${build_number}.ejs
