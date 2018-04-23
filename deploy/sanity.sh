#!/bin/bash

# Author Rajesh Rajendran <rajesh.r@optit.co>

config_dir=.sunbird
ssh_key=$1
bold=$(tput bold)
normal=$(tput sgr0)

# Application versions
es_version=5.4
docker_version=17.06
postgres_version=9.5
cassandra_version=3.9
java_version=1.8.0_162
ubuntu_version=16.06
docker_manager_ram=1
docker_node_ram=8
es_ram=2
db_ram=2


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
    nssh -o ConnectTimeout=2 $1 exit 0 &> /dev/null
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
        # Checking for elastic search version
        local version=$(nssh $ip curl -sS $ip:9200 | grep number| awk '{print $3}')
        echo -ne "\e[0;35m Elastic search Version: \e[0;32m$version "
        check_compatibility version "$version" "$es_version"
        # Check RAM
        local ram_=$(($(ram $ip)+1))
        echo -ne "\e[0;35m Elastic search RAM: \e[0;32m${ram_}G "
        check_compatibility ram $ram_ "$es_ram"
    done
}

check_cassandra() {
    echo -e "\e[0;36m ${bold}Checking Cassandra${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        # Checking for elastic search version
        local version=$(nssh $ip "cqlsh localhost 9042 -e 'select release_version from system.local;'" | tail -3 | head -n1)
        echo -ne "\e[0;35m Cassandra Version: \e[0;32m$version "
        check_compatibility version "$version" "$cassandra_version"
    done
}

check_postgres() {
    echo -e "\e[0;36m ${bold}Checking Postgres${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        # Checking for Postgres Version
        local version=$(nssh $ip pg_config --version )
        echo -ne "\e[0;35m Postgres Version: \e[0;32m$version "
        check_compatibility version "$version" "$postgres_version"
    done
}

# Checking docker
check_docker() {
    echo -e "\e[0;36m ${bold}Checking Docker $2 ${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        local version=$(nssh $ip docker --version | head -n1 | awk '{print $3" "$4" "$5}')
        echo -ne "\e[0;35m Docker Version: \e[0;32m $version"
        check_compatibility version "$version" "$docker_version"
        local ram_=$(($(ram $ip)+1))
        echo -ne "\e[0;35m Docker $2 RAM: \e[0;32m${ram_}G "
        local docker_ram=$docker_$2_ram
        check_compatibility ram $ram_ "$docker_ram"
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
check_docker $swarm_manager_ips manager
check_docker $swarm_node_ips node
postgres_ips=$postgres_master_ips,$postgres_slave_ips
check_postgres $postgres_ips
check_cassandra $cassandra_ips

if [[ $fail ]];then 
    echo -e "\n\e[0;31m ${bold}PLEASE RECTIFY THE ISSUES AND RUN AGAIN${normal}\n" 
    exit 1
fi
