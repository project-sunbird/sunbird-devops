#!/bin/bash

# 1. SSH connectivity
# 2. Check for application installation
#       app version
#       DB check for user and dbs
# 3. Check for h/w req
 
config_dir=.sunbird
ssh_key=$1
bold=$(tput bold)
normal=$(tput sgr0)

# Application versions
es_version=5.4
docker_version=18.06

# Refreshing ssh-agent
eval $(ssh-agent) &> /dev/null

# Adding key to ssh-agent
ssh-add $ssh_key &> /dev/null

# Sourcing the variables
source $config_dir/generate_host.sh &> /dev/null

result() {
    if [[ $1 -ne 0 ]];then
         echo -e "\e[0;31m${bold} FAILED${normal}"
         fail=1
    else
         echo -e "\e[0;32m${bold} OK${normal}"
    fi
}

ssh_connection() {
    echo -en "\e[0;35m SSH connection to $1 "
    ssh -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking false" -o ConnectTimeout=2 $(whoami)@$1 exit 0 &> /dev/null
    result $?
}

check_compatibility() {
    if [[ "$1" == *"$2"* ]];then result $? ; else result $?; fi
}

# Checks for elastic search
check_es() {
    echo -e "\e[0;36m ${bold}Checking elasticsearch${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        echo -ne "\e[0;35m Elastic search Version: "
        echo -ne "\e[0;32m "
        local version=$(curl -sS $ip:9200 | grep number)
        echo -ne $version
        check_compatibility "$version" "$es_version" 
    done
    
}

# Checking docker
check_docker() {
    echo -e "\e[0;36m ${bold}Checking Docker${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        echo -ne "\e[0;35m Docker Version: "
        echo -ne "\e[0;32m "
        local version=$(docker --version | head -n1 | awk '{print $3" "$4" "$5}')
        echo -ne $version
        check_compatibility "$version" "$docker_version"
    done
}

# Checking Ansible
check_ansible() {
    echo -e "\e[0;36m ${bold}Checking Docker${normal}"
    ansible --version | head -n1
}
check_es $elasticsearch_ips
docker_ips=$swarm_manager_ips,$swarm_node_ips
check_docker $docker_ips

if [[ $fail ]];then 
    echo "\e[0;31mplease rectify the issues and run again" 
    exit 1
fi
