#!/bin/bash -xv
read -p "Enter the github username: " user
read -sp "Enter the password: " pass
echo " "
statusChecks=0
IFS=','
#read input from a file
grep -v -e '#' -e "^$" github.csv | while read -ra LINE
do
   repo_name="${LINE[0]}"
   branch_name="${LINE[1]}"
   users="${LINE[2]}"
   check="${LINE[3]}"
unset IFS
Users=\"$users\"
githubUsers=$(echo $Users | sed 's/;/\",\"/g')
echo "------------------------------------------------------------------"
echo -e '\033[0;32m'$repo_name $branch_name $githubUsers $check'\033[0m'
echo "------------------------------------------------------------------"
IFS=','
if [[ $check == "1" ]]; then
        statusChecks='"Codacy/PR Quality Review"'
elif [[ $check == "2" ]]; then
        statusChecks='"ci/circleci: build"'
elif [[ $check == "3" ]]; then
        statusChecks='"Codacy/PR Quality Review",
                      "ci/circleci: build"'
else
        echo "Provide correct value!"
fi

curl -u $user:$pass -XPUT \
     -H 'Accept: application/vnd.github.luke-cage-preview+json' \
     -d '{
      "protection": {
        "enabled": true
      },

      "enforce_admins": true,
      "required_pull_request_reviews": {
          "dismiss_stale_reviews": true,
          "require_code_owner_reviews": false,
          "required_approving_review_count": 1
      },

      "required_status_checks": {
          "strict": true,
            "contexts": [
              '"$statusChecks"'
            ]
      },
      
      "restrictions": {
          "users": [
            '"$githubUsers"'
          ],
          "teams": [
            "null"
          ]
      }
    }' "https://api.github.com/repos/project-sunbird/$repo_name/branches/$branch_name/protection"
done
