#!/bin/bash

# Protocal validation
check_proto(){
if ! [[ "$2" =~ ^(http|https)$ ]]; then
  echo -e "\e[0;31m${bold}ERROR - Invalid value for $1. Valid values are http / https${normal}"
  fail=1
fi
}

# IP Validation
check_ip(){
if [[ "$2" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  OIFS=$IFS
  IFS='.'
  ip=($2)
  IFS=$OIFS
  if ! [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]; then
    echo -e "\e[0;31m${bold}ERROR - Invalid value for $1. Value for each IP group ranges from 0-255${normal}"
    fail=1
  fi
else
  echo -e "\e[0;31m${bold}ERROR - Invalid value for $1. IP address should be of the form 10.10.10.10${normal}"
  fail=1
fi
}

# CIDR block validation
check_cidr(){
if [[ "$2" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-3][0-9]$ ]]; then
  ip=`echo $2 | awk -F "/" '{print $1}'`
  block=`echo $2 | awk -F "/" '{print $2}'`
  OIFS=$IFS
  IFS='.'
  ip=($ip)
  IFS=$OIFS
  if ! [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 && $block -le 32 && $block -gt 0 ]]; then
     echo -e "\e[0;31m${bold}ERROR - Invalid value for $1. Value for each IP group ranges from 0-255 and CIDR blocks range from 1-32${normal}"
     fail=1
  fi
else
  echo -e "\e[0;31m${bold}ERROR - Invalid value for $1. CIDR is of the form 10.0.0.0/24 and blocks range from 1-32${normal}"
  fail=1
fi
}

# Basic email validation
check_email(){
if ! [[ "$2" =~ ^([a-zA-Z0-9])*@([a-zA-Z0-9])*\.([a-zA-Z0-9])*$ ]]; then
  echo -e "\e[0;31m${bold}ERROR - Invalid value for $1. Email must be of the format admin@sunbird.com${normal}"
  fail=1
fi
}

# Login to server using username and private key
check_login(){
echo -e "\e[0;33mValidating login to server..."
response=`ssh -i $2 -o StrictHostKeyChecking=no $3@$4 "whoami"`
if ! [[ "$response" == "$3" ]]; then
  echo -e "\e[0;31m${bold}ERROR - Login failed. Please check the username / private key / server address${normal}"
  fail=1
fi
}

# Validate user can run sudo commands using the sudo password
check_sudo(){
echo -e "\e[0;33mValidating sudo password..."
result=`ssh -i $4 -o StrictHostKeyChecking=no $3@$5 "echo $2 | sudo -S apt-get check"`
if ! [[ "$result" =~ (Reading|Building) ]]; then
  echo -e "\e[0;31m${bold}ERROR - Sudo login failed. Please check the username / password"
  fail=1
fi
echo ""
}


echo -e "\e[0;33m${bold}Validating the config file...${normal}"
bold=$(tput bold)
normal=$(tput sgr0)
core_install=$1

# Create an array with keys from config file
declare -a keys=($(sed -n '/.*:/p' config | awk -F ":" '($1 !~ /#/) {print $1}'))

# Create an empty array which will hold the values of keys
declare -A values

# Create an array with the values of keys. Reading the config file based on key, for example env: dev where key = env, and value dev will be read from config file
for i in "${keys[@]}"
do
  val=`awk ''/^$i:$' /{ if ($2 !~ /#.*/) {print $2}}' config`
  declare values[$i]=$val
done

# Validate the values obtained from config file
for i in "${!values[@]}"
do
  key=$i
  value=${values[$i]}

  if [[ "$key" == "proto" ]]; then check_proto $key $value;
  elif [[ "$key" =~ ^(application_host|database_host)$ ]]; then 
  check_ip $key $value;
  elif [[ "$key" == "app_address_space" ]]; then 
  check_cidr $key $value;
  elif [[ "$key" =~ ^(cert_path|key_path)$ && "$value" == "" && "${values[proto]}" == "https" ]]; then 
  echo -e "\e[0;31m${bold}ERROR - Protocal https specified but no value for $key entered. Please fill this value${normal}"; fail=1;
  elif [[ "$key" == "badger_admin_email" ]]; then 
  check_email $key $value;
  elif [[ "$key" == "ekstep_api_base_url" && ! "$value" =~ ^(https://api-qa.ekstep.in|https://api.ekstep.in)$ ]]; then 
  echo -e "\e[0;31m${bold}ERROR - Valid values for $key are https://api.ekstep.in or https://api-qa.ekstep.in${normal}"; fail=1;
  elif [[ "$key" == "ekstep_proxy_base_url" && ! "$value" =~ ^(https://community.ekstep.in|https://qa.ekstep.in)$ ]]; then 
  echo -e "\e[0;31m${bold}ERROR - Valid values for $key are https://community.ekstep.in or https://qa.ekstep.in${normal}"; fail=1;
  elif [[ "$key" == "ansible_private_key_path" && ! "$value" == "" &&  ! "${values[ssh_ansible_user]}" == "" && ! "${values[dns_name]}" == "" ]]; then 
  check_login $key $value ${values[ssh_ansible_user]} ${values[dns_name]}
  elif [[ "$key" == "sudo_passwd" && ! "$value" == "" && ! "${values[ssh_ansible_user]}" == "" && ! "${values[dns_name]}" == "" && ! "${values[ansible_private_key_path]}" == "" ]]; then 
  check_sudo $key $value ${values[ssh_ansible_user]} ${values[ansible_private_key_path]} ${values[dns_name]};
  elif [[ "$key" =~ ^(env|implementation_name|ssh_ansible_user|dns_name|database_password|keycloak_admin_password|sso_password|backup_storage_key|badger_admin_password|ekstep_api_key|sunbird_image_storage_url|sunbird_azure_storage_key|sunbird_azure_storage_account|sunbird_default_channel)$ && "$value" == "" ]]; then  
  echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value${normal}"; fail=1;
  elif [[ "$key" == "sunbird_sso_publickey" && "$core_install" == "core" && "$value" == "" ]]; then
  echo -e "\e[0;31m${bold}ERROR - Value for $key cannot be empty. Please fill this value before running core"; fail=1
  fi
done

if [[ $fail ]]; then
  echo -e "\e[0;31m${bold}Config file has errors. Please rectify the issues and rerun${normal}"
  exit 1
else
  echo -e "\e[0;32m${bold}Config file successfully validated${normal}"
fi
