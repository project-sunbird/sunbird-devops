#!/bin/bash
# Build script
# set -o errexit

apk add --no-cache git python make g++
cd sunbird-portal/src/app
npm install
./node_modules/.bin/gulp download:editors
cd client
npm install
npm run build-cdn -- --deployUrl $1
mv ../dist/index.html ../dist/index.ejs
