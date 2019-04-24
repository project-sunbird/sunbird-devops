#!/bin/bash
# Build script
# set -o errexit
set -x

sed -i '/jessie-updates/d' /etc/apt/sources.list
apt update && apt install git python make g++ jq zip -y
su jenkins
cd src/app
version=$(jq '.version' package.json | sed 's/\"//g')
cdnUrl=$1
build_hash=$2
artifact_version=$3
npm install
./node_modules/.bin/gulp download:editors
cd client
npm install
npm run build-cdn -- --deployUrl $cdnUrl
cd ..
# Gzipping of assets
./node_modules/.bin/gulp gzip:editors client:gzip
mv dist/index.html dist/index.${version}.${build_hash}.ejs
