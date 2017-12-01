#!/bin/sh
# Build script
# set -o errexit
# apk -v --update --no-cache add jq
# apk -v --update --no-cache add ansible=2.3.0.0-r1
# apk -v --update --no-cache add rsync
# apk -v --update --no-cache add whois
apt-get update
apt-get install -y whois
apt-get install -y jq

