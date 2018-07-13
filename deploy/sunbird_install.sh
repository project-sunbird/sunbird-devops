#!/bin/bash

#--------------------------------------------------------------------------------------------------------#
# This script installs and configures sunbird according to the confugurations specified in config file
#
# Usage 
#   ./sunbird_install.sh                    ==> Install and configure sunbird from scratch
#   ./sunbird_install.sh -h                 ==> Help
#   ./sunbird_install.sh -s <service name>  ==> Install the specific service
#
# Original Author: Rajesh Rajendran <rajesh.r@optit.co>
# Maintainers: Manoj <manojv@illimi.in>
#---------------------------------------------------------------------------------------------------------#

set -eu -o pipefail

usage() { echo "Usage: $0 [ -s {sanity|config|dbs|apis|proxy|keycloak|badger|core|logger|monitor|posttest} ]" ; exit 0; }

# Checking for valid argument
if [[ ! -z ${1:-} ]] && [[  ${1} != -* ]]; then
    usage
    exit 1
fi

# Sourcing versions of images
source version.env

# Reading environment and implementation name
implementation_name=$(awk '/implementation_name: /{ if ($2 !~ /#.*/) {print $2}}' config)
env_name=$(awk '/env: /{ if ($2 !~ /#.*/) {print $2}}' config)
app_host=$(awk '/application_host: /{ if ($2 !~ /#.*/) {print $2}}' config)
db_host=$(awk '/database_host: /{ if ($2 !~ /#.*/) {print $2}}' config)
ssh_ansible_user=$(awk '/ssh_ansible_user: /{ if ($2 !~ /#.*/) {print $2}}' config)
ansible_private_key_path=$(awk '/ansible_private_key_path: /{ if ($2 !~ /#.*/) {print $2}}' config)
ansible_variable_path="${implementation_name}"-devops/ansible/inventories/"$env_name"
protocol=$(awk '/proto: /{ if ($2 !~ /#.*/) {print $2}}' config)
domainname=$(awk '/dns_name: /{ if ($2 !~ /#.*/) {print $2}}' config)

#TO skip the host key verification
export ANSIBLE_HOST_KEY_CHECKING=False
#Enable force color
export ANSIBLE_FORCE_COLOR=true

# Creating logging directory
if [ ! -d logs ];then mkdir logs &> /dev/null;fi
# Creating temporary directory
if [ ! -d .sunbird/ignore ];then mkdir -p .sunbird/ignore &> /dev/null;fi

# Generating configs
config() { 
    sudo ./install-deps.sh
    time ./generate-config.sh $implementation_name $env_name core;
    # Creating inventory
    sed -i s#\"{{database_host}}\"#$db_host#g $ansible_variable_path/hosts
    sed -i s#\"{{application_host}}\"#$app_host#g $ansible_variable_path/hosts
    sed -i s#\"{{ansible_private_key_path}}\"#$ansible_private_key_path#g $ansible_variable_path/hosts
    ansible-playbook -i "localhost," -c local ../ansible/generate-hosts.yml --extra-vars @config --extra-vars "host_path=$ansible_variable_path"
    .sunbird/generate_host.sh  > $ansible_variable_path/hosts 2>&1 /dev/null
}

# Sanity check

sanity() {
    ./sanity.sh $ssh_ansible_user $ansible_private_key_path
}

# Installing dependencies
deps() { 
ansible-playbook -i $ansible_variable_path/hosts ../ansible/sunbird_prerequisites.yml --extra-vars @config 
ansible-playbook -i $ansible_variable_path/hosts ../ansible/setup-dockerswarm.yml --extra-vars @config 
}


# Installing and initializing dbs
dbs() { ./install-dbs.sh $ansible_variable_path; ./init-dbs.sh $ansible_variable_path; }

# Apis
apis() { ./deploy-apis.sh $ansible_variable_path; }

# Proxy
proxy() { ./deploy-proxy.sh $ansible_variable_path; }

# Keycloak
keycloak() {  
    ./provision-keycloak.sh $ansible_variable_path
    ./deploy-keycloak-vm.sh $ansible_variable_path 
    sleep 15
    ./bootstrap-keycloak.sh $ansible_variable_path
}

# badger
badger() { ./deploy-badger.sh $ansible_variable_path; }

# Core
core() { ./deploy-core.sh $ansible_variable_path; }

# Logger
logger() { ./deploy-logger.sh $ansible_variable_path; }

# Monitor
monitor() { ./deploy-monitor.sh $ansible_variable_path; }

#Post Installation Testing
posttest() { ./postInstallation.sh $ansible_private_key_path $ssh_ansible_user $protocol $domainname; }

while getopts "s:h" o;do
    case "${o}" in
        s)
            s=${OPTARG}
            case "${s}" in
                config)
                    echo -e "\n$(date)\n">>logs/config.log;
                    config 2>&1 | tee -a logs/config.log
                    exit 0
                    ;;
                sanity)
                    echo -e "\n$(date)\n">>logs/sanity.log;
                    config 2>&1 | tee -a logs/sanity.log
                    sanity 2>&1 | tee -a logs/sanity.log
                    exit 0
                    ;;
                deps)
                    echo -e "\n$(date)\n">>logs/deps.log;
                    sudo ./install-deps.sh 2>&1 | tee -a logs/deps.log
                    deps 2>&1 | tee -a logs/deps.log
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
                badger)
                    echo -e "\n$(date)\n">>logs/badger.log; badger 2>&1 | tee -a logs/badger.log
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
		    echo -e "\n$(date)\n">>logs/proxy.log; proxy 2>&1 | tee -a logs/proxy.log
                    echo -e "\n$(date)\n">>logs/monitor.log; monitor 2>&1 | tee -a logs/monitor.log
                    exit 0   
                    ;;
                posttest)
                    echo -e "\n$(date)\n">>logs/postInstallationLogs.log;
                    config 2>&1 | tee -a logs/postInstallationLogs.log
                    posttest 2>&1 | tee -a logs/postInstallationLogs.log
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

## Installing and configuring prerequisites
echo -e \n$(date)\n >> logs/config.log; config 2>&1 | tee -a logs/config.log
## checking for prerequisites
echo -e \n$(date)\n >> logs/sanity.log; sanity 2>&1 | tee -a logs/sanity.log
echo -e \n$(date)\n >> logs/deps.log; deps 2>&1 | tee -a logs/deps.log

## Installing services and dbs
echo -e \n$(date)\n >> logs/dbs.log; dbs 2>&1 | tee -a logs/dbs.log
echo -e \n$(date)\n >> logs/apis.log; apis 2>&1 | tee -a logs/apis.log
echo -e \n$(date)\n >> logs/proxies.log; proxy 2>&1 | tee -a logs/proxies.log
echo -e \n$(date)\n >> logs/keycloak.log; keycloak 2>&1 | tee -a logs/keycloak.log
echo -e \n$(date)\n >> logs/badger.log; badger 2>&1 | tee -a logs/badger.log
