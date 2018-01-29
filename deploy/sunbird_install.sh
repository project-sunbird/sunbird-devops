#!/bin/bash

set -eu -o pipefail

usage() { echo "Usage: $0 [ -s {config|dbs|apis|proxy|keycloak} ]" 1>&2; exit 1; }

# Reading environment and implimentation name
IMPLIMENTATION_NAME=$(awk '/implementation_name: / {print $2}' config)
ENV_NAME=$(awk '/env: / {print $2}' config)
APP_HOST=$(awk '/application_host: / {print $2}' config)
DB_HOST=$(awk '/database_host: / {print $2}' config)
SSH_ANSIBLE_USER=$(awk '/ssh_ansible_user: / {print $2}' config)
SSH_ANSIBLE_FILE=$(awk '/ssh_ansible_file: / {print $2}' config)
ANSIBLE_PRIVATE_KEY_PATH=$(awk '/ansible_private_key_path: / {print $2}' config)
ANSIBLE_VARIABLE_PATH=$IMPLIMENTATION_NAME-devops/ansible/inventories/$ENV_NAME

# Installing dependencies
deps() { sudo ./install-deps.sh; }

# Generating configs
config() { 
    time ./generate-config.sh $IMPLIMENTATION_NAME $ENV_NAME core; 
    # Creating inventory
    sed -i s#\"{{database_host}}\"#$DB_HOST#g $ANSIBLE_VARIABLE_PATH/hosts
    sed -i s#\"{{application_host}}\"#$APP_HOST#g $ANSIBLE_VARIABLE_PATH/hosts
    sed -i s#\"{{ssh_ansible_user}}\"#$SSH_ANSIBLE_USER#g $ANSIBLE_VARIABLE_PATH/hosts
    sed -i s#\"{{ssh_ansible_file}}\"#$SSH_ANSIBLE_FILE#g $ANSIBLE_VARIABLE_PATH/hosts
    sed -i s#\"{{ansible_private_key_path}}\"#$ANSIBLE_PRIVATE_KEY_PATH#g $ANSIBLE_VARIABLE_PATH/hosts
}


# Installing and initializing dbs
dbs() { ./install-dbs.sh $ANSIBLE_VARIABLE_PATH; ./init-dbs.sh $ANSIBLE_VARIABLE_PATH; }

# Apis
apis() { ./deploy-apis.sh $ANSIBLE_VARIABLE_PATH; }

# Proxy
proxy() { ./deploy-proxy.sh $ANSIBLE_VARIABLE_PATH; }

# Keycloak
keycloak() { ./provision-keycloak.sh $ANSIBLE_VARIABLE_PATH; ./deploy-keycloak-vm.sh $ANSIBLE_VARIABLE_PATH; }

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
