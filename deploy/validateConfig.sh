#/bin/bash

# Trampoline secret length validation
check_tram_secret(){
key=$1
value=$2
length=$(echo $value | awk '{print length}')
if [[ $length -lt 8 ]]; then
   echo -e "\e[0;31m${bold}ERROR - Invalid value for $key. Value must be at least 8 characters in length"
   fail=1
fi
}


# Basic phone number validation
check_phone(){
key=$1
value=$2
length=$(echo $value | awk '{print length}')
if [[ $length -lt 8 || $value =~ [a-zA-Z] ]]; then
   echo -e "\e[0;31m${bold}ERROR - Invalid value for $key. Phone number cannot include alphabets and should contain 8 digits minimum${normal}"
   fail=1
fi
}


# Basic email validation
check_email(){
key=$1
value=$2
if ! [[ $value =~ ^([a-zA-Z0-9])*@([a-zA-Z0-9])*\.([a-zA-Z0-9])*$ ]]; then
   echo -e "\e[0;31m${bold}ERROR - Invalid value for $key. Email must be of the format admin@sunbird.com${normal}"
   fail=1
fi
}


# Check if the CIDR value specified in app_address_space is valid
check_cidr(){
key=$1
value=$2
IFS="./" read -r ip1 ip2 ip3 ip4 N <<< $value
ip=$(($ip1 * 256 ** 3 + $ip2 * 256 ** 2 + $ip3 * 256 + $ip4))
if ! [[ $(($ip % 2**(32-$N))) = 0 ]]; then
   echo -e "\e[0;31m${bold}ERROR - Invalid CIDR value for $key. Please enter a valid value. CIDR is of the format 172.10.0.0/24"
   fail=1
   cidr_result="fail"
fi
}


# Check if the IP address belongs to the CIDR block specified in app_address_space
check_ip(){
key=$1
value=$2
if [[ ${vals[app_address_space]} != "" && $cidr_result != "fail" ]]; then
   IFS="." read -r host_ip1 host_ip2 host_ip3 host_ip4 <<< $value
   IFS="./" read -r cidr_ip1 cidr_ip2 cidr_ip3 cidr_ip4 N <<< ${vals[app_address_space]}
   set -- $(( 5 - ($N / 8))) 255 255 255 255 $(((255 << (8 - ($N % 8))) & 255 )) 0 0 0
   [ $1 -gt 1 ] && shift $1 || shift
   mask=${1-0}.${2-0}.${3-0}.${4-0}
   IFS="." read -r mask_ip1 mask_ip2 mask_ip3 mask_ip4 <<< $mask
   net_addr=$((cidr_ip1&mask_ip1)).$((cidr_ip2&mask_ip2)).$((cidr_ip3&mask_ip3)).$((cidr_ip4&mask_ip4))
   broad_addr=$((cidr_ip1&mask_ip1^(255-$mask_ip1))).$((cidr_ip2&mask_ip2^(255-$mask_ip2))).$((cidr_ip3&mask_ip3^(255-$mask_ip3))).$((cidr_ip4&mask_ip4^(255-$mask_ip4)))
   cidr_trim=$cidr_ip1.$cidr_ip2.$cidr_ip3.$cidr_ip4
   ip_post_mask=$((host_ip1&mask_ip1)).$((host_ip2&mask_ip2)).$((host_ip3&mask_ip3)).$((host_ip4&mask_ip4))
   range_start=$((cidr_ip1&mask_ip1)).$((cidr_ip2&mask_ip2)).$((cidr_ip3&mask_ip3)).$(((cidr_ip4&mask_ip4)+1))
   range_end=$((cidr_ip1&mask_ip1^(255-$mask_ip1))).$((cidr_ip2&mask_ip2^(255-$mask_ip2))).$((cidr_ip3&mask_ip3^(255-$mask_ip3))).$(((cidr_ip4&mask_ip4^(255-$mask_ip4))-1))
   if ! [[ $ip_post_mask == $cidr_trim && $value > $net_addr && $value < $broad_addr ]]; then
      echo -e "\e[0;31m${bold}ERROR - Invalid value for $key. IP address does not belong to the CIDR group. Valid range for given app_address_space is $range_start to $range_end${normal}"
      fail=1
   fi
fi
}


# Check if login succeeds to the app and db server using username and private key
check_login(){
key=$1
value=$2
app_server=${vals[application_host]}
db_server=${vals[database_host]}
username=${vals[ssh_ansible_user]}

app_user=$(ssh -i $value -o StrictHostKeyChecking=no -o ConnectTimeout=1  $username@$app_server whoami 2> /dev/null)
db_user=$(ssh -i $value -o StrictHostKeyChecking=no -o ConnectTimeout=1 $username@$db_server whoami 2> /dev/null)

if [[ $app_user != $username ]]; then
   echo -e "\e[0;31m${bold}ERROR - Login to app server failed. Please check application_host, ssh_ansible_user, ansible_private_key_path${normal}"
   fail=1
fi

if [[ $db_user != $username ]]; then
   echo -e "\e[0;31m${bold}ERROR - Login to db server failed. Please check database_host, ssh_ansible_user, ansible_private_key_path${normal}"
   fail=1
fi
}


# Validate ssh_ansible_user can run sudo commands using the sudo password
check_sudo(){
key=$1
value=$2
app_server=${vals[application_host]}
db_server=${vals[database_host]}
username=${vals[ssh_ansible_user]}
private_key=${vals[ansible_private_key_path]}

result=$(ssh -i $private_key -o StrictHostKeyChecking=no  -o ConnectTimeout=1 $username@$app_server "echo $value | sudo -S apt-get check" 2> /dev/null)
if ! [[ $result =~ (Reading|Building) ]]; then
   echo -e "\e[0;31m${bold}ERROR - Sudo login failed. Please check the username / password / IP"
   fail=1
fi
}


# Function to retrieve values of mandatory fields and store it as key value pair
get_config_values(){
key=$1
vals[$key]=$(awk ''/^$key:' /{ if ($2 !~ /#.*/) {print $2}}' config)
}

# Script start. core_install will receive value as "core" from calling script when -s core option is triggered.
bold=$(tput bold)
normal=$(tput sgr0)
if ! [[ $# -eq 0 ]]; then
core_install=$1
else
core_install="NA"
fi

echo -e "\e[0;33m${bold}Validating the config file...${normal}"


# An array of mandatory values
declare -a arr=("env" "implementation_name" "ssh_ansible_user" "sudo_passwd" "ansible_private_key_path" "application_host" "app_address_space" "dns_name" "proto" "cert_path" \
     "key_path" "database_host" "database_password" "keycloak_admin_password" "sso_password" "trampoline_secret" "backup_storage_key" "badger_admin_password" \
     "badger_admin_email" "ekstep_api_base_url" "ekstep_proxy_base_url" "ekstep_api_key" "sunbird_image_storage_url" "sunbird_azure_storage_key" \
     "sunbird_azure_storage_account" "sunbird_custodian_tenant_name" "sunbird_custodian_tenant_description" "sunbird_custodian_tenant_channel" \
     "sunbird_root_user_firstname" "sunbird_root_user_lastname" "sunbird_root_user_username" "sunbird_root_user_password" "sunbird_root_user_email" \
     "sunbird_root_user_phone" "sunbird_sso_publickey" "sunbird_default_channel")

# Create and empty array which will store the key and value pair from config file
declare -A vals

# Iterate the array and retrieve values for mandatory fields from config file
for i in ${arr[@]}
do
get_config_values $i
done

# Iterate the array of key values and based on key check the validation
for i in ${!vals[@]}
do
key=$i
value=${vals[$i]}
case $key in
   proto)
       if [[ ! "$value" =~ ^(http|https)$ ]]; then
          echo -e "\e[0;31m${bold}ERROR - Invalid value for $key. Valid values are http / https${normal}"; fail=1
       fi
       ;;
   cert_path|key_path)
       if [[ "$value" == "" && "${vals[proto]}" == "https" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Protocal https specified but $key is blank. Please fill this value${normal}"; fail=1
       fi
       ;;
   ekstep_api_base_url)
       if [[ ! "$value" =~ ^(https://api-qa.ekstep.in|https://api.ekstep.in)$ ]]; then
          echo -e "\e[0;31m${bold}ERROR - Valid values for $key are https://api.ekstep.in or https://api-qa.ekstep.in${normal}"; fail=1
       fi
       ;;
   ekstep_proxy_base_url)
       if [[ ! "$value" =~ ^(https://community.ekstep.in|https://qa.ekstep.in)$ ]]; then
          echo -e "\e[0;31m${bold}ERROR - Valid values for $key are https://community.ekstep.in or https://qa.ekstep.in${normal}"; fail=1
       fi
       ;;
   trampoline_secret)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value with a minimum of 8 characters${normal}"; fail=1
       else
          check_tram_secret $key $value
       fi
       ;;
   sunbird_root_user_phone)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value with a minimum of 8 digits${normal}"; fail=1
       else
          check_phone $key $value
       fi
       ;;
   badger_admin_email|sunbird_root_user_email)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value${normal}"; fail=1
       else
          check_email $key $value
       fi
       ;;
   app_address_space)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value${normal}"; fail=1
       else
          check_cidr $key $value
       fi
       ;;
   application_host|database_host)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value${normal}"; fail=1
       else
          check_ip $key $value
       fi
       ;;
   ansible_private_key_path)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value${normal}"; fail=1
       else
          check_login $key $value
       fi
       ;;
   sudo_passwd)
       if [[ $value != "" ]]; then
          check_sudo $key $value
       fi
       ;;
   sunbird_sso_publickey)
       if [[ $core_install == "core" && $value == "" ]]; then
       echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value before running core"; fail=1
       fi
       ;;
   *)
       if [[ "$value" == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value${normal}"; fail=1
       fi
       ;;
esac
done

# Check if any of the validation failed and exit
if [[ $fail ]]; then
   echo -e "\e[0;31m${bold}Config file has errors. Please rectify the issues and rerun${normal}"
   exit 1
else
   echo -e "\e[0;32m${bold}Config file successfully validated${normal}"
fi
