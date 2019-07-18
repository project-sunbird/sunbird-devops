#!/bin/bash
read -p "Enter Github Username: " user
read -sp "Enter Github Password: " pass
echo " "
IFS=','
grep -v -e '#' -e "^$" github.csv | while read -ra LINE
do
   repo_name="${LINE[0]}"
   echo "----------------------------------------------------"
   echo -e '\033[0;32m'$repo_name'\033[0m'
   echo "----------------------------------------------------"
   curl -u $user:$pass -s -N https://api.github.com/repos/project-sunbird/$repo_name/branches | jq '.[].name' -r
done
