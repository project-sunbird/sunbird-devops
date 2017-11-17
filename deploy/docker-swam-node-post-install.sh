#!/bin/sh

set -x

# This is to ensure we don't get below error
# Failed to start container manager: inotify_init: too many open files
# Reference: https://github.com/moby/moby/issues/1044
sysctl -w fs.inotify.max_user_instances=8192