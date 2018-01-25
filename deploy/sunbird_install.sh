#!/bin/bash

set -e

usage() { echo "Usage: $0 [ -s {config|dbs|apis|proxy|keycloak} ]" 1>&2; exit 1; }

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
                    echo -e "\n$(date)\n">>config.log; config 2>&1 | tee -a config.log
                    exit 0
                    ;;
                dbs)
                    echo -e "\n$(date)\n">>dbs.log; dbs 2>&1 | tee -a dbs.log
                    exit 0
                    ;;
                apis)
                    echo -e "\n$(date)\n">>apis.log; apis 2>&1 | tee -a apis.log
                    exit 0
                    ;;
                proxy)
                    echo -e "\n$(date)\n">>proxy.log; proxy 2>&1 | tee -a proxy.log
                    exit 0
                    ;;
                keycloak)
                    echo -e "\n$(date)\n">>keycloak.log; keycloak 2>&1 | tee -a keycloak.log
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
echo -e \n$(date)\n >> deps.log; deps 2>&1 | tee -a deps.log
echo -e \n$(date)\n >> config.log; config 2>&1 | tee -a config.log
echo -e \n$(date)\n >> dbs.log; dbs 2>&1 | tee -a dbs.log
echo -e \n$(date)\n >> apis.log; apis 2>&1 | tee -a apis.log
echo -e \n$(date)\n >> proxies.log; proxy 2>&1 | tee -a proxies.log
echo -e \n$(date)\n >> keycloak.log; keycloak 2>&1 | tee -a keycloak.log
