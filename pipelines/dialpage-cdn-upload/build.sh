#!/bin/bash
# Build script
# set -o errexit
env=$1
apk add --no-cache git python make g++
cd sunbird-portal/dial-code-page
pwd
echo ========================================================================
echo ========================================================================
echo ========================================================================
echo ========================================================================
npm install
npm run build
echo =================== build completed
# Created dist folder
# Replace only staging
if [[ ${env} == staging ]];then
    sed -i s#https://dev.open-sunbird.org#https://staging.open-sunbird.org#g dist/script.js
fi
