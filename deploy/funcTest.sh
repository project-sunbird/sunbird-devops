#!/bin/bash
# AUTHOR: S M Y ALTAMASH <smy.altamash@gmail.com>

ssh_key=$1
ssh_user=$2
protocol=$3
serverIP=$4

config_dir=.sunbird
echo "-----------------------------------------"
echo "Checking Databases:-"
echo ""

# Sourcing the variables
source $config_dir/generate_host.sh &> /dev/null

if [ ! -z $ssh_key ];then
    # Refreshing ssh-agent
    eval $(ssh-agent) &> /dev/null
    # Adding key to ssh-agent
    ssh-add $ssh_key &> /dev/null
fi

if [ -d .sunbird/ignore ]; then mkdir -p .sunbird/ignore; fi
rm -rf .sunbird/ignore/*

nssh() {
    ssh -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking false" -o "LogLevel ERROR" $@
    return $?
}

check_es() {
    ips $1
    for ip in ${arr[@]}; do
	local outpt=$(nssh $ssh_user@$ip "sudo netstat -ntpl | grep 9200 | awk 'NR==1{print $4}' | cut -d \":\" -f2" )
	local outpt1=$(curl -XGET -s "$ip:9200/_cluster/health" | jq ".status")
	if [ "$outpt1" == "\"green\"" ] || [ "$outpt1" == "\"yellow\"" ] && [ "$outpt" -eq 9200 ];then
        	echo "ELASTICSEARCH cluster is healthy"
	else
		echo "ELASTICSEARCH cluster is unhealthy"
        fi
	break
     done
}


check_postgres() {
    ips $1
    for ip in ${arr[@]}; do
        local outpt2=$(nssh $ssh_user@$ip "ps -ef | grep postgres | wc -l" )
        local outpt3=$(nc -z $ip 5432; echo $? ) 
	if [ "$outpt2" -gt 1 ] && [ "$outpt3" -eq 0 ];then
                echo "POSTGRES is working in $ip"
        else
                echo "POSTGRES is Not Working in $ip"
        fi
     done
}

check_cassandra() {
    ips $1
    for ip in ${arr[@]}; do
        local outpt4=$(nssh $ssh_user@$ip "ps -ef | grep cassandra | wc -l" )
        local outpt5=$(nc -z $ip 9042; echo $? )
	if [ "$outpt4" -gt 1 ] && [ "$outpt5" -eq 0 ];then
                echo "CASSANDRA is working in $ip"
        else
                echo "CASSANDRA is Not Working in $ip"
        fi
     done
}



check_es $elasticsearch_ips
postgres_ips=$postgres_master_ips,$postgres_slave_ips
check_postgres $postgres_ips
check_cassandra $cassandra_ips
python3 statusChecks.py $protocol $serverIP
