#!/bin/sh
# Build script
# set -o errexit

cd sunbird-portal/src/app/client
pwd
echo ==================
printenv
echo ==================
npm install
npm run build-cdn -- --deployUrl $1
