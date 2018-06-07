#!/bin/bash
# Build script
# set -o errexit

apk add --no-cache git
npm install -g gulp-cli
cd sunbird-portal/src/app
gulp download:editors
cd client
npm install
npm run build-cdn -- --deployUrl $1
mv ../dist/index.html ../dist/index.ejs
