#!/bin/sh
# Build script
# set -o errexit
apk -v --update --no-cache add jq
apk -v --no-cache add ansible=2.3.0.0-r1
