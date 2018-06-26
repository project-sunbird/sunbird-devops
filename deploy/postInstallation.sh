#!/bin/bash
# AUTHOR: S M Y ALTAMASH <smy.altamash@gmail.com>
 
ssh_key=$1
ssh_user=$2
protocol=$3
serverIP=$4
ServiceLogsFolder=logs/service_logs/
config_dir=.sunbird
echo "---------------------------------------------------------------------------------"
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
    ip=${arr[0]}
	local outpt=$(nssh $ssh_user@$ip "sudo netstat -ntpl | grep 9200 | awk 'NR==1{print $4}' | cut -d \":\" -f2" )
	local outpt1=$(curl -XGET -s "$ip:9200/_cluster/health" | jq ".status")
	local outpt2=$(curl -XGET -s "$ip:9200" | jq ".version.number")
	if [ "$outpt1" == "\"green\"" ] || [ "$outpt1" == "\"yellow\"" ] && [ "$outpt" -eq 9200 ];then
        	echo "ELASTICSEARCH cluster is healthy"
		echo -e "The Version of Elasticsearch being used is \"$outpt2\"\n"
	else
		echo -e "ELASTICSEARCH cluster is unhealthy\n"
        fi
}


check_postgres() {
    ips $1
    for ip in ${arr[@]}; do
        local outpt2=$(nssh $ssh_user@$ip "ps -ef | grep postgres | wc -l" )
	local outpt4=$(nssh $ssh_user@$ip "/usr/lib/postgresql/9.5/bin/postgres --version")
        local outpt3=$(nc -z $ip 5432; echo $? ) 
	if [ "$outpt2" -gt 1 ] && [ "$outpt3" -eq 0 ];then
                echo "POSTGRES is working in $ip"
        else
                echo "POSTGRES is Not Working in $ip"
        fi
     echo  "The Postgres version which is being used is \"$outpt4\""
     done
     echo -e "\n"
}

check_cassandra() {
    ips $1
    for ip in ${arr[@]}; do
    local outpt4=$(nssh $ssh_user@$ip "ps -ef | grep cassandra | wc -l" )
    local outpt5=$(nc -z $ip 9042; echo $? )
    local outpt6=$(nssh $ssh_user@$ip "cqlsh --version")
	if [ "$outpt4" -gt 1 ] && [ "$outpt5" -eq 0 ];then
                echo "CASSANDRA is working in $ip"
        else
                echo "CASSANDRA is Not Working in $ip"
        fi
    done
    echo -e "The Cassandra version being used is \"$outpt6\" \n"
}

check_es_indices() {
    echo "-----------------------------------------"
    echo -e "Checking The Ealstic Search Indices:-\n"
    ips $1
    flag=0
    ip=${arr[0]}
    local outpt1=$(curl -XGET -s "$ip:9200/_cat/indices" | awk '{print $3}')
        if [ "$outpt1" == "searchindex" ];then
                echo "OK: ELASTICSEARCH indices exists"
        else
                echo "WARNING: ELASTICSEARCH indices does NOT EXISTS"
        fi
    echo "-----------------------------------------"
}

check_postgres_databases() {
        ips $1
	echo "-----------------------------------------"
        echo -e "Checking Postgres Databases:-\n"
        ip=${arr[0]}
	local outpt2=$(nssh $ssh_user@$ip 'sudo su postgres bash -c "psql -c \"SELECT datname FROM pg_database;\""' | awk 'NR>2' | head -n -2 | tr "\n" " ")
	dbNames=("api_manager" "keycloak" "quartz" "badger")
        flag=0
        for db in ${dbNames[@]}; do
          echo $outpt2 | grep $db &>/dev/null
          if [ $? -eq 1 ]; then
                echo "$db Database doesn't exist in Postgres"
                flag=1
          fi
        done

         if [ $flag -eq 0 ]; then
                echo "All the Databases Exists which are necessary for sunbird"
          fi
	echo "-----------------------------------------"
}

check_cassandra_keyspaces() {
    ips $1
    echo "-----------------------------------------"
    echo -e "Checking Cassandra Keyspaces:-\n"
    ip=${arr[0]}
    local outpt=$(nssh $ssh_user@$ip '/usr/bin/cqlsh -e "DESCRIBE  KEYSPACES"' | awk 'NR>1' | tr "\n" " " | sed 's/  */ /g')
    existingKeyspaces=("dialcodes" "system_auth" "sunbirdplugin" "sunbird portal")
    flag=0
    for db in ${existingKeyspaces[@]}; do
	echo $outpt | grep $db &>/dev/null
	if [ $? -eq 1 ]; then
		echo "$db Keyspace doesn't exist in Cassandra"
		flag=1
	fi
    done
       if [ $flag -eq 0 ]; then
		echo "All the Keyspaces Exists which are necessary for sunbird"
	fi
    echo "-----------------------------------------"
}

check_version() {
	list=(actor-service player_player learner-service content-service proxy_proxy api-manager_kong)
	versionReq=$(git branch | grep \* | cut -d '-' -f2)
	echo -e "The Sunbird Version being used is $versionReq \n"
	if [ $(git branch | grep \* | cut -d '-' -f2 | grep -Ewo '.' | wc -l) -ne 3 ]; then
		versionReq="${versionReq}.0"
	fi
        for service in ${list[@]}; do
	    versionGot=$( sudo docker service ls | grep  $service | awk '{ print $5 }' | cut -d ':' -f2 | cut -d '-' -f1)
            if [ "$versionReq" == "$versionGot" ]; then
		echo "OK: $service Version is as per the Latest Release"
	    else
	        echo "WARNING: $service Version is NOT as per the latest release,the version obtained is $versionGot"
	    fi
	done

}

get_logs() {
	mkdir -p $ServiceLogsFolder
	echo "Storing logs of core services in $ServiceLogsFolder"
	echo "-----------------------------------------"
	serviceNames=(player_player learner-service content-service proxy_proxy api-manager_kong)
	for service in ${serviceNames[@]}; do
		echo -e "\nexporting $service logs to $ServiceLogsFolder"
		sudo docker service logs $service --tail 10000 > $ServiceLogsFolder/$service
	done
}

check_service_health() {
	echo "-----------------------------------------"
        echo "Checking Service Health:-"
        echo ""
        proxyServerID=$(getent hosts $(sudo docker service ps proxy_proxy | grep Running | awk '{print $4}') | awk '{print $1}')
        echo "Proxy server IP is $proxyServerID"
        ansible-playbook  -i "$proxyServerID," ../ansible/servicehealth.yml --extra-vars "ansible_ssh_private_key_file=$ssh_key ansible_ssh_username=$ssh_user" 
}

check_es $elasticsearch_ips
postgres_ips=$postgres_master_ips,$postgres_slave_ips
check_postgres $postgres_ips
check_cassandra $cassandra_ips
python3 statusChecks.py $protocol $serverIP
check_version
check_es_indices $elasticsearch_ips
check_postgres_databases $postgres_master_ips
check_cassandra_keyspaces $cassandra_ips
get_logs
check_service_health

#Zipping Logs to send it via email
sudo apt-get install zip -y
zip -r logs logs/*
