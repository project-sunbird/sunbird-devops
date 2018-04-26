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

echo -e "\n\e[0;36m${bold}checking for sunbird prerequisites...${normal}"
echo -e "\e[0;32msuccess \e[0;31mfatal \e[0;33mwarning"

if [ -z $ssh_key ];then
    # Refreshing ssh-agent
    eval $(ssh-agent) &> /dev/null
    # Adding key to ssh-agent
    ssh-add $ssh_key &> /dev/null
fi

if [ -d .sunbird/ignore ]; then mkdir -p .sunbird/ignore; fi
rm -rf .sunbird/ignore/*

# Sourcing the variables
source $config_dir/generate_host.sh &> /dev/null

nssh() {
    ssh -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking false" -o "LogLevel ERROR" $@
    return $?
}

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
    nssh -o ConnectTimeout=2 $1 exit 0 &> /dev/null
    result $?
}

ram() {
    nssh $1 free -g | awk '{print $2}' | head -n2 | tail -1
}

check_compatibility() {
    local service_version=$2
    local version=$3
    local service_name=$4
    case $1 in
        version)
            if [[ "$service_version" == *"$version"* ]];then
                echo -e "\e[0;32m${bold} OK ${normal}"
                touch ".sunbird/ignore/${service_name}"
            else
                echo -e "\e[0;31m${bold} INCOMPATIBLE${normal}"
            fi
            ;;
        ram)
            if [[ $service_version -ge $version ]];then
                echo -e "\e[0;32m${bold} OK ${normal}"
            else 
                echo -e "\e[0;33m${bold} NOT ENOUGH ${normal}"
            fi
            ;;
    esac
}

# Checks for elastic search
check_es() {
    echo -e "\n\e[0;36m ${bold}Checking elasticsearch${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        # Checking for elastic search version
        if [ $(nssh $ip nc -z localhost 9200; echo $?) ];then
            local version=$(nssh $ip curl -sS $ip:9200 | grep number| awk '{print $3}')
            echo -ne "\e[0;35m Elastic search Version: \e[0;32m$version "
            check_compatibility version "$version" "$es_version" es
        else 
            echo -e "\e[0;35m Elastic search Version: \e[0;32m${bold}Not Installed${normal} "
        fi
        # Check RAM
        local ram_=$(($(ram $ip)+1))
        echo -ne "\e[0;35m Elastic search RAM: \e[0;32m${ram_}G "
        check_compatibility ram $ram_ "$es_ram"
    done
}

check_cassandra() {
    echo -e "\n\e[0;36m ${bold}Checking Cassandra${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        # Checking for cassandra version
        if [ $(nc -z $ip 9042; echo $? ) ];then
            local version=$(nssh $ip "cqlsh localhost 9042 -e 'select release_version from system.local;'" | tail -3 | head -n1)
            echo -ne "\e[0;35m Cassandra Version: \e[0;32m$version "
            check_compatibility version "$version" "$cassandra_version" es
        else 
            echo -e "\e[0;35m Cassandra Version: \e[0;32m${bold}Not Installed${normal} "
        fi
    done
}

check_postgres() {
    echo -e "\n\e[0;36m ${bold}Checking Postgres${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        # Checking for Postgres Version
        if [ $(nc -z $ip 5432; echo $? ) ];then
            local version=$(nssh $ip pg_config --version)
            echo -ne "\e[0;35m Postgres Version: \e[0;32m$version "
            check_compatibility version "$version" "$postgres_version" es
        else 
            echo -e "\e[0;35m Postgres Version: \e[0;32m${bold}Not Installed${normal} "
        fi
    done
}

# Checking docker
check_docker() {
    echo -e "\n\e[0;36m ${bold}Checking Docker $2 ${normal}"
    ips $1
    for ip in ${arr[@]}; do
        ssh_connection $ip
        if [ $(nssh $ip which docker) ];then
            local version=$(nssh $ip docker --version | head -n1 | awk '{print $3" "$4" "$5}')
            echo -ne "\e[0;35m Docker Version: \e[0;32m$version "
            check_compatibility version "$version" "$docker_version" es
        else 
            local version=$(nssh $ip docker --version | head -n1 | awk '{print $3" "$4" "$5}')
            echo $version
            echo -e "\e[0;35m Docker Version: \e[0;32m${bold}Not Installed${normal} "
        fi
        local ram_=$(($(ram $ip)+1))
        echo -ne "\e[0;35m Docker $2 RAM: \e[0;32m${ram_}G "
        local docker_ram=docker_${2}_ram
        check_compatibility ram $ram_ $docker_ram 
    done
}


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
