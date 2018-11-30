#!/bin/bash
set -e 
[[ $(which ansible) ]] || apk -v --update --no-cache add ansible
[[ $(which jq) ]] || apk -v --update --no-cache add jq
