#!/bin/sh

set -ex

git -C sunbird-devops pull || git clone https://github.com/project-sunbird/sunbird-devops.git sunbird-devops
