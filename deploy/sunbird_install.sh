#!/bin/bash

set -eu -o pipefail

usage() { echo "Usage: $0 [ -s {config|dbs|apis|proxy|keycloak|core|logger|monitor} ]" &>/dev/null; exit 0; }

# Reading environment and implimentation name
implimentation_name=$(awk '/implementation_name: / {print $2}' config)
env_name=$(awk '/env: / {print $2}' config)
app_host=$(awk '/application_host: / {print $2}' config)
db_host=$(awk '/database_host: / {print $2}' config)
ssh_ansible_user=$(awk '/ssh_ansible_user: / {print $2}' config)
ansible_private_key_path=$(awk '/ansible_private_key_path: / {print $2}' config)
ansible_variable_path=$implimentation_name-devops/ansible/inventories/$env_name

#TO skip the host key verification
export ANSIBLE_HOST_KEY_CHECKING=False

# Creating logging directory
if [ ! -d logs ];then mkdir logs &> /dev/null;fi

# Generating configs
config() { 
    time ./generate-config.sh $implimentation_name $env_name core; 
    # Creating inventory
    sed -i s#\"{{database_host}}\"#$db_host#g $ansible_variable_path/hosts
    sed -i s#\"{{application_host}}\"#$app_host#g $ansible_variable_path/hosts
    sed -i s#\"{{ansible_private_key_path}}\"#$ansible_private_key_path#g $ansible_variable_path/hosts
    ansible-playbook -i "localhost," -c local ../ansible/generate-hosts.yml --extra-vars @config --extra-vars @advanced --extra-vars "host_path=$ansible_variable_path"
    $ansible_variable_path/generate_host.sh  > $ansible_variable_path/hosts 2>&1
}

# Installing dependencies
deps() { sudo ./install-deps.sh; 
ansible-playbook -i $ansible_variable_path/hosts ../ansible/sunbird_prerequisites.yml --extra-vars @config --extra-vars @advanced
ansible-playbook -i $ansible_variable_path/hosts ../ansible/setup-dockerswarm.yml --extra-vars @config --extra-vars @advanced
}


# Installing and initializing dbs
dbs() { ./install-dbs.sh $ansible_variable_path; ./init-dbs.sh $ansible_variable_path; }

# Apis
apis() { ./deploy-apis.sh $ansible_variable_path; ./onboard-api-consumer.sh $ansible_variable_path; }

# Proxy
proxy() { ./deploy-proxy.sh $ansible_variable_path; }

# Keycloak
keycloak() {  
    ./provision-keycloak.sh $ansible_variable_path
    ./deploy-keycloak-vm.sh $ansible_variable_path 
    sleep 15
    ./bootstrap-keycloak.sh $ansible_variable_path
}

# Core
core() { ./deploy-core.sh $ansible_variable_path; }

# Logger
logger() { ./deploy-logger.sh $ansible_variable_path; }

# Logger
monitor() { ./deploy-monitor.sh $ansible_variable_path; }


while getopts "s:h" o;do
    case "${o}" in
        s)
            s=${OPTARG}
            echo "help.."
            case "${s}" in
                config)
                    echo -e "\n$(date)\n">>logs/config.log; config 2>&1 | tee -a logs/config.log
                    exit 0
                    ;;
                deps)
                    echo -e "\n$(date)\n">>logs/deps.log; deps 2>&1 | tee -a logs/config.log
                    exit 0
                    ;;
                dbs)
                    echo -e "\n$(date)\n">>logs/dbs.log; dbs 2>&1 | tee -a logs/dbs.log
                    exit 0
                    ;;
                apis)
                    echo -e "\n$(date)\n">>logs/apis.log; apis 2>&1 | tee -a logs/apis.log
                    exit 0
                    ;;
                proxy)
                    echo -e "\n$(date)\n">>logs/proxy.log; proxy 2>&1 | tee -a logs/proxy.log
                    exit 0
                    ;;
                keycloak)
                    echo -e "\n$(date)\n">>logs/keycloak.log; keycloak 2>&1 | tee -a logs/keycloak.log
                    exit 0
                    ;;
                core)
                    echo -e "\n$(date)\n">>logs/core.log; core 2>&1 | tee -a logs/core.log
                    exit 0
                    ;;
                logger)
                    echo -e "\n$(date)\n">>logs/logger.log; logger 2>&1 | tee -a logs/logger.log
                    exit 0
                    ;;
                monitor)
                    echo -e "\n$(date)\n">>logs/monitor.log; monitor 2>&1 | tee -a logs/monitor.log
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

echo -e \n$(date)\n >> config.log; config 2>&1 | tee -a logs/config.log
echo -e \n$(date)\n >> deps.log; deps 2>&1 | tee -a logs/deps.log
# Installing sunbird_ansible prerequisites
echo -e \n$(date)\n >> dbs.log; dbs 2>&1 | tee -a logs/dbs.log
echo -e \n$(date)\n >> apis.log; apis 2>&1 | tee -a logs/apis.log
echo -e \n$(date)\n >> proxies.log; proxy 2>&1 | tee -a logs/proxies.log
echo -e \n$(date)\n >> keycloak.log; keycloak 2>&1 | tee -a logs/keycloak.log
