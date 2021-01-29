#!/bin/bash

# Build script
set -eo pipefail

# Downloading deps
wget https://codeload.github.com/simplresty/ngx_devel_kit/tar.gz/v0.3.0 -O ngx_devel_kit_0_3_0.tar.gz
wget https://codeload.github.com/openresty/luajit2/tar.gz/v2.1-20190626 -O luajit_2_1.tar.gz
wget https://codeload.github.com/openresty/lua-nginx-module/tar.gz/v0.10.15 -O ngx_lua.tar.gz

# Creating deps directory
mkdir -p nginx_devel_kit luajit nginx_lua
tar --strip-components=1 -xf ngx_devel_kit_0_3_0.tar.gz -C nginx_devel_kit
tar --strip-components=1 -xf luajit_2_1.tar.gz -C luajit
tar --strip-components=1 -xf ngx_lua.tar.gz -C nginx_lua

# Creating nginx
build_tag=$1
name=proxy
node=$2
org=$3

docker build -t ${org}/${name}:${build_tag} .
echo {\"image_name\" : \"${name}\", \"image_tag\" : \"${build_tag}\", \"node_name\" : \"$node\"} > metadata.json
