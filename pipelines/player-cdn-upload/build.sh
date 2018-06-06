#!/bin/sh
# Build script
# set -o errexit

home_dir=$(pwd)
cd sunbird-portal/src/app/client
pwd
npm install
npm run build-cdn -- --deployUrl $1
