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
if ! [[ $value =~ ^([a-zA-Z0-9]).*@([a-zA-Z0-9]).*\.([a-zA-Z0-9]).*$ ]]; then
   echo -e "\e[0;31m${bold}ERROR - Invalid value for $key. Email must be of the format admin@sunbird.com${normal}"
   fail=1
fi
}


# Check if the CIDR value specified in app_address_space is valid
check_cidr(){
key=$1
value=$2
cidr_result="OK"
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

   IFS="." read -r hip1 hip2 hip3 hip4 <<< $value
   host_ip=$(($hip1 * 256 ** 3 + $hip2 * 256 ** 2 + $hip3 * 256 + $hip4))

   # Obtain the netmask
   IFS="./" read -r cip1 cip2 cip3 cip4 N <<< ${vals[app_address_space]}
   set -- $(( 5 - ($N / 8))) 255 255 255 255 $(((255 << (8 - ($N % 8))) & 255 )) 0 0 0
   [ $1 -gt 1 ] && shift $1 || shift
   mask=${1-0}.${2-0}.${3-0}.${4-0}
   IFS="." read -r mip1 mip2 mip3 mip4 <<< $mask

   # Network address - Formula to calculate is cidr ip bitwise AND with mask ip
   # Ex: 172.30.0.0 & 255.255.0.0 = 172.30.0.0 (First address)
   nip1=$((cip1&mip1))
   nip2=$((cip2&mip2))
   nip3=$((cip3&mip3))
   nip4=$((cip4&mip4))
   net_ip=$(($nip1 * 256 ** 3 + $nip2 * 256 ** 2 + $nip3 * 256 + $nip4))

   # Broadcast address - Formula to calculate is cidr ip bitwise AND with mask ip then XOR with 255 - mask IP
   # Ex: 172.30.0.0 & 255.255.0.0 ^ 0.0.255.255 = 172.30.255.255 (Last address)
   bip1=$((cip1&mip1^(255-$mip1)))
   bip2=$((cip2&mip2^(255-$mip2)))
   bip3=$((cip3&mip3^(255-$mip3)))
   bip4=$((cip4&mip4^(255-$mip4)))
   broad_ip=$(($bip1 * 256 ** 3 + $bip2 * 256 ** 2 + $bip3 * 256 + $bip4))

   # Bitwise AND host ip with mask ip to obtain CIDR block.
   # Example: 172.30.30.55 & 255.255.0.0 = 172.30.0.0 (CIDR)
   hipm1=$((hip1&mip1))
   hipm2=$((hip2&mip2))
   hipm3=$((hip3&mip3))
   hipm4=$((hip4&mip4))

   cidr_trim=$cip1.$cip2.$cip3.$cip4
   ip_mask=$hipm1.$hipm2.$hipm3.$hipm4

   range_start=$nip1.$nip2.$nip3.$((nip4 + 1))
   range_end=$bip1.$bip2.$bip3.$((bip4 - 1))


   if ! [[ $ip_mask == $cidr_trim && $host_ip -gt $net_ip && $host_ip -lt $broad_ip ]]; then
      echo -e "\e[0;31m${bold}ERROR - Invalid value for $key. IP address does not belong to the CIDR group. Valid range for given app_address_space is $range_start to $range_end${normal}"
      fail=1
   fi
fi
}


# Check if login succeeds to the app, db, es, cass and pg master server using username and private key if values are not null
check_login(){
key=$1
value=$2
username=${vals[ssh_ansible_user]}

for j in ${!arr_hosts[@]}
do
  if [[ ${arr_hosts[$j]} != "" ]]; then
     login_user=$(ssh -i $value -o StrictHostKeyChecking=no -o ConnectTimeout=1  $username@${arr_hosts[$j]} whoami 2> /dev/null)

     if [[ $login_user != $username ]]; then
        echo -e "\e[0;31m${bold}ERROR - Login to ${index_keys[$j]} failed. Please check ${index_keys[$j]}, ssh_ansible_user, ansible_private_key_path${normal}"
        fail=1
     fi
  fi
done
}


# Validate ssh_ansible_user can run sudo commands using the sudo password
check_sudo(){
key=$1
value=$2
username=${vals[ssh_ansible_user]}
private_key=${vals[ansible_private_key_path]}

for j in ${!arr_hosts[@]}
do
  if [[ ${arr_hosts[$j]} != "" ]]; then
     result=$(ssh -i $private_key -o StrictHostKeyChecking=no  -o ConnectTimeout=1 $username@${arr_hosts[$j]} "echo $value | sudo -S apt-get check" 2> /dev/null)

     if ! [[ $result =~ (Reading|Building) ]]; then
        echo -e "\e[0;31m${bold}ERROR - Sudo check failed. Please check the value provided in ssh_ansible_user, $key, ansible_private_key_path, ${index_keys[$j]}${normal}"
        fail=1
     fi
fi
done
}


# Function to retrieve values of mandatory fields and store it as key value pair
get_config_values(){
key=$1
vals[$key]=$(awk ''/^$key:' /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
}

# Script start. core_install will receive value as "core" from calling script when -s core option is triggered.
bold=$(tput bold)
normal=$(tput sgr0)
fail=0
if ! [[ $# -eq 0 ]]; then
   core_install=$1
else
   core_install="NA"
fi

echo -e "\e[0;33m${bold}Validating the config file...${normal}"


# An array of mandatory values
declare -a arr=("env" "implementation_name" "ssh_ansible_user" "dns_name" "proto" "cert_path" "key_path" "keycloak_admin_password" \
                "sso_password" "trampoline_secret" "backup_storage_key" "badger_admin_password" "badger_admin_email" "ekstep_api_base_url" \
                "ekstep_proxy_base_url" "ekstep_api_key" "sunbird_image_storage_url" "sunbird_azure_storage_key" "sunbird_azure_storage_account" \
                "sunbird_custodian_tenant_name" "sunbird_custodian_tenant_description" "sunbird_custodian_tenant_channel" "sunbird_root_user_firstname" \
                "sunbird_root_user_lastname" "sunbird_root_user_username" "sunbird_root_user_password" "sunbird_root_user_email" "sunbird_root_user_phone" \
                "sunbird_sso_publickey" "app_address_space" "application_host" "database_host" "sudo_passwd" \
                "ansible_private_key_path" "elasticsearch_host" "cassandra_host" "postgres_master_host" "database_password" "postgres_keycloak_password" \
                "postgres_app_password" "postgres_kong_password" "postgres_badger_password" "cassandra_password")

# Create and empty array which will store the key and value pair from config file
declare -A vals

# Iterate the array and retrieve values for mandatory fields from config file
for i in ${arr[@]}
do
get_config_values $i
done

# An array of all the IP addresses which we will use to test login and sudo privilege
declare -a arr_hosts=("${vals[application_host]}" "${vals[database_host]}" "${vals[elasticsearch_host]}" "${vals[cassandra_host]}" "${vals[postgres_master_host]}")
declare -a index_keys=("application_host" "database_host" "elasticsearch_host" "cassandra_host" "postgres_master_host")

# Iterate the array of key values and based on key check the validation
for i in ${arr[@]}
do
key=$i
value=${vals[$key]}
case $key in
   proto)
       if [[ ! "$value" =~ ^(http|https)$ ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Valid values are http / https${normal}"; fail=1
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
   application_host)
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
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value before running core${normal}"; fail=1
       fi
       ;;
   database_host)
       if [[ $value != "" ]]; then
          check_ip $key $value
       fi
       ;;
   elasticsearch_host|cassandra_host|postgres_master_host)
       if [[ $value != "" ]]; then
           check_ip $key $value
       elif [[ $value == "" &&  ${vals[database_host]} == "" ]]; then
           echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value OR provide value for database_host which will be default DB${normal}"; fail=1
       fi
       ;;
   database_password)
       continue
       ;;
   postgres_keycloak_password|postgres_app_password|postgres_kong_password|postgres_badger_password|cassandra_password)
       if [[ ${vals[database_password]} == "" && $value == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key is empty. Please provide fill this value OR provide value for database_password which will be default password${normal}"; fail=1
       fi
       ;;

   *)
       if [[ $value == "" ]]; then
          echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value${normal}"; fail=1
       fi
       ;;
esac
done


# Check if any of the validation failed and exit
if [[ $fail -eq 1 ]]; then
   echo -e "\e[0;34m${bold}Config file has errors. Please rectify the issues and rerun${normal}"
   exit 1
else
   echo -e "\e[0;32m${bold}Config file successfully validated${normal}"
fi
