#!/bin/bash

set -e

usage() { echo "Usage: $0 [ -s {config|dbs|apis|proxy|keycloak|core} ]" 1>&2; exit 1; }

# Reading environment and implimentation name
IMPLIMENTATION_NAME=$(awk '/implementation_name: / {print $2}' config)
ENV_NAME=$(awk '/environment: / {print $2}' config)

ANSIBLE_VARIABLE_PATH=$IMPLIMENTATION_NAME-devops/ansible/inventories/$ENV_NAME/group_vars/$ENV_NAME

# Installing dependencies
deps() { sudo ./install-deps.sh; }

# Generating configs
config() { time ./generate-config.sh $IMPLIMENTATION_NAME $ENV_NAME core; }

# Installing and initializing dbs
dbs() { ./install-dbs.sh $ANSIBLE_VARIABLE_PATH; ./init-dbs.sh $ANSIBLE_VARIABLE_PATH; }

# Apis
apis() { ./deploy-apis.sh $ANSIBLE_VARIABLE_PATH; }

# Proxy
proxy() { ./deploy-proxy.sh; }

# Keycloak
keycloak() { ./provision-keycloak.sh; ./deploy-keycloak-vm.sh; }

while getopts "s:h" o;do
    case "${o}" in
        s)
            s=${OPTARG}
            echo "help.."
            case "${s}" in
                config)
                    config 2>&1 | tee config.log
                    exit 0
                    ;;
                dbs)
                    dbs 2>&1 | tee dbs.log
                    exit 0
                    ;;
                apis)
                    apis 2>&1 | tee apis.log
                    exit 0
                    ;;
                proxy)
                    proxy 2>&1 | tee proxy.log
                    exit 0
                    ;;
                keycloak)
                    keycloak 2>&1 | tee keycloak.log
                    exit 0
                    ;;
                *)
                    usage
                    exit 0
                    ;;
            esac
            ;;

        *)
            usage
            exit 0
            ;;
    esac
done

# Default action: install and configure from scratch
deps 2>&1 | tee deps.log
config 2>&1 | tee config.log
dbs 2>&1 | tee dbs.log
apis 2>&1 | tee apis.log
proxy 2>&1 | tee proxies.log
keycloak 2>&1 | tee keycloak.log
