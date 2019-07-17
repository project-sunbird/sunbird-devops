#!/bin/bash
read -p "Enter Github Username: " user
read -sp "Enter Github Password: " pass
echo " "   
IFS=','
grep -v -e '#' -e "^$" github.csv | while read -ra LINE
do
   repo_name="${LINE[0]}"
   branch_name="${LINE[1]}"
   echo "----------------------------------------------------"
   echo -e '\033[0;32m'$repo_name' '$branch_name'\033[0m'
   echo "----------------------------------------------------"
   curl -u $user:$pass -XDELETE \
      -H "Accept: application/vnd.github.loki-preview+json" \
      -d '{
      "protection": {
        "enabled": null
      },
        "restrictions": null,
        "required_status_checks": null,
        "enforce_admins": null,
        "required_pull_request_reviews": null
    }' "https://api.github.com/repos/project-sunbird/$repo_name/branches/$branch_name/protection"
done
