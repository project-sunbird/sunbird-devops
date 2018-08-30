#!/bin/bash
# Build script
# set -o errexit
# set -x

apk add --no-cache git python make g++ jq
cd sunbird-portal/src/app
version=$(jq '.version' package.json | sed 's/\"//g')
build_hash=$(jq '.buildHash' ../../../metadata.json | sed 's/\"//g')
npm install
./node_modules/.bin/gulp download:editors
cd client
npm install
npm run build-cdn -- --deployUrl $1
cd ..
# Gzipping of assets
./node_modules/.bin/gulp gzip:editors client:gzip
mv dist/index.html dist/index.${version}.${build_hash}.ejs
