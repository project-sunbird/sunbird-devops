#!/bin/bash
read -p "Enter Github Username: " user
read -sp "Enter Github Password: " pass
echo " "
read -p "Enter Github Account Name: " acc_name
echo "---------------------------------------------"
echo -e '\033[0;32m'$acc_name'\033[0m'
echo "---------------------------------------------"
curl -s -N https://api.github.com/users/$acc_name/repos\?per_page=100 | jq '.[].name' -r
