#!/bin/bash
# AUTHOR: S M Y ALTAMASH <smy.altamash@gmail.com>

ssh_key=$1
ssh_user=$2
protocol=$3
serverIP=$4
fName="testname"
lName="testname"
phone="8095414779"
passwdd="testname"
userName="testname"
mail='smy.altamash@gmail.com'

#Organisation Name

orgName="DevOPS"
orgDescription="This is my organisation"
channelName="myChannel"


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
	if [ "$outpt1" == "\"green\"" ] && [ "$outpt" -eq 9200 ];then
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

addUser() {
	ki=`curl -s -X POST $protocol://$serverIP/api/user/v1/create \
        -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJjYzMwMmYwNDVmMTk0YzUyODVmMzFiNjkxZDVlMDQ5NiJ9.jzVokk3WaedtZnVz5aw1GfTJcqwN5j9ajRBZX4-Drhs' \
         -H 'cache-control: no-cache' \
         -H 'content-type: application/json' \
         -H 'postman-token: 5d781505-7264-d4ff-b795-476756538469' \
         -H 'ts: 2018-02-21 16:14:56:578+0530' \
         -H 'x-consumer-id: X-Consumer-ID' \
         -H 'x-msgid: 8e27cbf5-e299-43b0-bca7-8347f7e5abcf' \
         -d "{  
        \"request\":  
        {  
        \"firstName\": \"$fName\", 
        \"lastName\": \"$lName\", 
        \"password\": \"$passwdd\", 
        \"userName\": \"$userName\", 
        \"email\": \"$mail\", 
        \"phone\": \"$phone\"
       } 
        } 
          " -k | jq '.result.userId'`
	echo "$ki" >> ~/uid.txt
}

getAuthorisation() {
	autho=`curl -s -X POST \
  http://$serverIP/auth/realms/sunbird/protocol/openid-connect/token \
  -H 'cache-control: no-cache' \
  -H 'application\json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'postman-token: 350ca3cd-3a4f-28bf-2c92-0b7d67c5a79d' \
  -d 'client_id=admin-cli&username=$userName&password=$passwdd&grant_type=password' | jq '.access_token'`
	echo "$autho" >> ~/authorization_token.txt
}

addOrganisation() {
	addorg=`curl -s -X POST $protocol://$serverIP/api/org/v1/create \
 -H 'accept: application/json' \
 -H 'authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJjYzMwMmYwNDVmMTk0YzUyODVmMzFiNjkxZDVlMDQ5NiJ9.jzVokk3WaedtZnVz5aw1GfTJcqwN5j9ajRBZX4-Drhs ' \
 -H 'content-type: application/json' \
 -H "x-authenticated-user-token: $ki"\
 -H 'x-consumer-id: X-Consumer-ID' \
 -H 'x-device-id: X-Device-ID' \
 -d '{
 "request":{ 
   "orgName": "$orgName",
    "description" :"$orgDescription",
    "channel": "$channelName",
    "isRootOrg": true    
 }
}
' -k | jq '.result.organisationId'`
	echo "$addorg" >> ~/organisation_token.txt
}



userManagement() {
	addUser
	getAuthorisation
	addOrganisation
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
#userManagement 
