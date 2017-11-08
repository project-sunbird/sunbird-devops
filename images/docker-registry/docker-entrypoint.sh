#!/bin/sh
set -e
htpasswd -bBn $REGISTRY_INITIAL_USER "$REGISTRY_INITIAL_PASSWORD" >> htpasswd
case "$1" in
    *.yaml|*.yml) set -- registry serve "$@" ;;
    serve|garbage-collect|help|-*) set -- registry "$@" ;;

esac
exec "$@"