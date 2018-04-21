#!/bin/bash

# Author Rajesh Rajendran <rajesh.r@optit.co>

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
docker_version=17.06
postgres_version=
cassandra_version=
java_version=
ubuntu_version=
docker_manager_ram=
docker_node_ram=
es_ram=2
db_ram=


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

nssh() {
    ssh -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking false" -o "LogLevel ERROR" $@
}

ssh_connection() {
    echo -en "\e[0;35m SSH connection to $1 "
    nssh -o ConnectTimeout=2 $(whoami)@$1 exit 0 &> /dev/null
    result $?
}

ram() {
    nssh $1 free -g | awk '{print $2}' | head -n2 | tail -1
}

check_compatibility() {
    case $1 in
        version) if [[ "$2" == *"$3"* ]];then result $? ; else result $?; fi ;;
        ram) if [[ $2 -ge $3 ]];then result $? ; else result $?; fi ;;
    esac
}

# Checks for elastic search
check_es() {
    echo -e "\e[0;36m ${bold}Checking elasticsearch${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        local version=$(curl -sS $ip:9200 | grep number| awk '{print $3}')
        echo -ne "\e[0;35m Elastic search Version: \e[0;32m$version "
        check_compatibility version "$version" "$es_version"
        # Check RAM
        local ram_=$(($(ram $ip)+1))
        echo -ne "\e[0;35m Elastic search RAM: \e[0;32m${ram_}G "
        check_compatibility ram $ram_ "$es_ram"
    done
}

# Checking docker
check_docker() {
    echo -e "\e[0;36m ${bold}Checking Docker${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        local version=$(docker --version | head -n1 | awk '{print $3" "$4" "$5}')
        echo -ne "\e[0;35m Docker Version: \e[0;32m $version"
        check_compatibility version "$version" "$docker_version"
    done
}

# Checking Ansible
check_ansible() {
    echo -e "\e[0;36m ${bold}Checking Ansible${normal}"
    local version=$(ansible --version | head -n1)
    echo -ne "\e[0;35m Ansible Version: \e[0;32m$version "
    check_compatibility version "$version" "$ansible_version"
}

check_ansible
check_es $elasticsearch_ips
docker_ips=$swarm_manager_ips,$swarm_node_ips
check_docker $docker_ips

if [[ $fail ]];then 
    echo -e "\n\e[0;31m ${bold}PLEASE RECTIFY THE ISSUES AND RUN AGAIN${normal}\n" 
    exit 1
fi
