#!/bin/sh
# Build script
# set -o errexit

cd sunbird-portal/src/app/client
npm install
npm run build-cdn -- --deployUrl $1
cd ..
ls
echo "uploading dist azure"
