#!/bin/bash

usage() { echo "Usage: $0 -s {config|dbs|apis|proxy|keycloak|core}" 1>&2; exit 1; }

# Reading environment and implimentation name
implimentation_name=$(awk '/implementation_name: / {print $2}' mcf)
env_name=$(awk '/environment: / {print $2}' mcf)

ansible_variable_path=$implimentation_name-devops/ansible/inventories/$env_name/group_vars/$env_name

# Installing dependencies
sudo ./install-deps.sh

# Generating configs
config() { ./generate-config.sh $implimentation_name $env_name core; }

# Installing and initializing dbs
dbs() { ./install-dbs.sh $ansible_variable_path; ./init-dbs.sh $ansible_variable_path; }

# Apis
apis() { ./deploy-apis.sh $ansible_variable_path; }

# Proxy
proxy() { ./deploy-proxy.sh; }

# Keycloak
keycloak() { ./provision-keycloak.sh; ./deploy-keycloak-vm.sh; }

# Core services
core() { ./deploy-core.sh; }

while getopts "s:h" o;do
    case "${o}" in
        s)
            s=${OPTARG}
            echo "help.."
            case "${s}" in
                config)
                    config
                    ;;
                dbs)
                    dbs
                    ;;
                apis)
                    apis
                    ;;
                proxy)
                    proxy
                    ;;
                keycloak)
                    keycloak
                    ;;
                *)
                    usage
                    ;;
            esac
            ;;
        *)
            usage
            ;;
    esac
done
