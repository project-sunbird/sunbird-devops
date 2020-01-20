# vim: set ft=sh ts=4 sw=4 tw=0 et :
#!/bin/bash
set -eo pipefail
#{{{
BOLD="$(tput bold)"
RED="${BOLD}$(tput setaf 1)"
GREEN="${BOLD}$(tput setaf 2)"
YELLOW="${BOLD}$(tput setaf 3)"
WHITE="$(tput sgr0)${BOLD}"
NORMAL="$(tput sgr0)"
#}}}
jwt_token=$(sudo cat /root/jwt_token_player.txt | xargs)
# Variable declaration {{{

categories="medium board gradeLevel subject"
org="sunbird"
framework="sunbird"
board="sunbird"
# Array of values
medium=("english" "hindi" "malayalam")
gradeLevel=("class1" "class2" "class3")
subject=("maths" "english" "science")
# Overriding variables
source 3node.vars
learning_host="${kp_ip}:8080/learning-service"

#}}}

echo installing jq
sudo apt install jq -y

# Creating form and other apis{{{

# Creating license
curl --location --request POST 'localhost:12000/content/license/v3/create' \
--header 'Content-Type: application/json' \
--data-raw '{
    "request":{
        "license":{
            "name": "CC BY 4.0",
            "description": "License description",
            "url": "URL"
        }
    }
}'

echo -e "\nCreating x-auth token"
x_auth_token=$(curl -Ss --location --request POST "https://${domain_name}/auth/realms/sunbird/protocol/openid-connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header "Authorization: Bearer ${jwt_token}" \
--data-raw 'client_id=admin-cli&password=password&grant_type=password&username=admin' | jq '.access_token' | xargs )
echo x_auth_token=$x_auth_token >> ~/api_details.txt

# Creating root org
echo -e "Creating root org\n"
echo $rootOrg
curl -Ss --location --request POST "https://${domain_name}/api/org/v1/create" \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header "x-authenticated-user-token: ${x_auth_token}" \
--data-raw '
{
  "request":
  {
    "orgName": "'${org}'",
    "description": "'${org}'",
    "isRootOrg": true,
    "channel": "'${org}'"
  }
}' | jq '.'

echo -e "\n\n waiting for org to get created\n\n"
sleep 10

echo Getting OrgId
org_id=$(curl -Ss --location --request POST "https://${domain_name}/api/org/v1/search" \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header 'x-authenticated-user-token: ${x_auth_token}' \
--data-raw '{
  "request":
  {
    "filters": {
    "orgName": "'${org}'"
    }
  }
}' | jq '.result.response.content[0].id' | xargs
)

[[ $org_id ]] || (echo -e"\n\nempty organization id"; exit 100)

echo $org_id
# Creating channel
echo -e "\n\nCreating channel"
echo $channel
curl --location --request POST --header 'Content-Type: application/json' \
 "http://${learning_host}/channel/v3/create" \
 --data-raw '
{
  "request": {
     "channel":{
   "name":"'${org}'",
   "description":"'${org}' Channel",
   "code":"'${org_id}'"
     }
   }
}'

# Creating framework
curl --location --request POST "${learning_host}/framework/v3/create" \
--header 'Content-Type: application/json' \
--header "X-Channel-Id: ${org_id}" \
--data-raw '
{
  "request": {
    "framework": {
      "name": "'${framework}'",
      "description": "'${framework}' framework",
      "code": "'${framework}'",
      "channels":[
        {
          "identifier":"'${org_id}'"
        }
      ]
    }
  }
}'

# Updating default framework for channel
curl --location --request PATCH "${learning_host}/channel/v3/update/${org_id}" \
--header 'Content-Type: application/json' \
--data-raw '{
   "request": {
      "channel":{
          "defaultFramework": "'${framework}'",
          "defaultLicense": "CC BY - 4.0"

      }
    }
}'

sleep 2

# custodian org
curl --location --request POST "https://${domain_name}/api/data/v1/system/settings/set" \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header "x-authenticated-user-token: ${x_auth_token}" \
--data-raw '{
	"request": {
        "id": "custodianOrgId",
        "field": "custodianOrgId",
        "value": "'${org_id}'"
    }
}'

curl --location --request POST "https://${domain_name}/api/data/v1/system/settings/set" \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header "x-authenticated-user-token: ${x_auth_token}" \
--data-raw '{
	"request": {
        "id": "custodianOrgChannel",
        "field": "custodianOrgChannel",
        "value": "'${org}'" 
    }
}'


# Creating categories
echo -e "\n\nCreating categories"
for item in $categories; do
    echo -e "\n Creating master category"
    curl --location --request POST "${learning_host}/framework/v3/category/master/create" \
    --header 'Content-Type: application/json' \
    --header "X-Channel-Id: ${org_id}" \
    --data-raw '{
       "request": {
          "category":{
              "name":"'${item}'",
              "description":"",
              "code":"'${item}'"
          }
        }
    }'

    echo -e "\n Creating category"
        curl --location --request POST "${learning_host}/framework/v3/category/create?framework=${framework}" \
        --header 'Content-Type: application/json' \
        --data-raw '
    {
       "request": {
          "category":{
              "name":"'${item}'",
              "description":"'${item}'",
              "code":"'${item}'"
          }
        }
    }'
done

# Creating terms
echo hi
echo -e "\n\nCreating terms"
for item in $categories;do
    terms=${!item}
    for term in "$terms";do
    echo $term
        curl --location --request POST "${learning_host}/framework/v3/term/create?framework=${framework}&category=${item}" \
        --header 'Content-Type: application/json' \
        --data-raw ' {
        "request": {
           "term": {
                "name": "'${term}'",
                "code": "'${term}'",
                "description":"'${term}'"
            }
         }
        }'
        sleep .5
    done
    sleep .5
done

sleep 1
# Publishing framework
echo -e "\n\nPublising framework"
curl --location --request POST "${learning_host}/framework/v3/publish/${framework}" \
--header 'Content-Type: application/json' \
--header "X-Channel-Id: ${org}" \
--data-raw '{
    "id": "ekstep.framework.publish",
    "ver": "3.0",
    "request": {
    }
}'

sleep 1
# Creating user
curl --location --request POST "https://${domain_name}/api/user/v1/create" \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header "x-authenticated-user-token: ${x_auth_token}" \
--data-raw '
{
    "request":
    {
        "firstName": "'${username}'",
        "lastName": "'${username}'",
        "password": "'${password}'",
        "phone": "'${phone_number}'",
        "userName": "'${username}'",
        "channel": "'${org}'",
        "phoneVerified": true
    }
}'

sleep 3

# Assigning user role
user_id=$(curl --location --request POST "https://${domain_name}/api/user/v1/search" \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header "x-authenticated-user-token: ${x_auth_token}" \
--data-raw '{
    "request":
    {
        "filters": {
        "phone": "'${phone_number}'",
        "userName": "'${username}'"
        }
    }
}' | jq '.result.response.content[].organisations[].userId' | xargs
)
echo user id: $user_id

curl --location --request POST "https://${domain_name}/api/user/v1/role/assign" \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header "x-authenticated-user-token: ${x_auth_token}" \
--data-raw '{
    "request":
    {
        "organisationId": "'${org_id}'",
        "userId": "'${user_id}'",
        "roles": ["CONTENT_CREATOR","CONTENT_REVIEWER","ORG_ADMIN","BOOK_CREATOR","BOOK_REVIEWER","COURSE_MENTOR"]
    }
}'

# Creating location
curl --location --request POST "https://${domain_name}/api/data/v1/location/create" \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header "x-authenticated-user-token: ${x_auth_token}" \
--data-raw '{
"params": { },
   "request":{
          "type":"state",
          "name":"Kerala",
          "code":"kl",
          "parentCode": ""
    }
}'
sleep 2
curl --location --request POST "https://${domain_name}/api/data/v1/location/create" \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--header 'accept: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--header "x-authenticated-user-token: ${x_auth_token}" \
--data-raw '{
"params": { },
   "request":{
          "type":"district",
          "name":"Trivandrum",
          "code":"trv",
          "parentCode": "kl"
    }
}'


# Form Creation
## resource
curl --location --request POST "https://${domain_name}/api/data/v1/form/create" \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--data-raw '{
	"request": {
		"type": "content",
		"subType": "resource",
		"action": "create",
		"framework": "'${org}'",
		"rootOrgId": "'${org_id}'",
        "data": {
                "templateName": "defaultTemplate",
                "action": "create",
                "fields": [
                    {
                        "code": "name",
                        "dataType": "text",
                        "name": "Name",
                        "lable": "Name",
                        "description": "Name",
                        "editable": true,
                        "placeholder": "Name",
                        "inputType": "text",
                        "required": false,
                        "displayProperty": "Editable",
                        "visible": true,
                        "renderingHints": {
                            "width": "twelve"
                        },
                        "index": 1,
                        "validation": [
                            {
                                "type": "regex",
                                "value": "^[a-zA-Z0-9\\s]*$",
                                "message": "Invalid Input"
                            },
                            {
                                "type": "max",
                                "value": "75",
                                "message": "Input is Exceded"
                            }
                        ]
                    },
                    {
                        "code": "description",
                        "dataType": "text",
                        "name": "Description",
                        "lable": "Description",
                        "description": "description",
                        "editable": true,
                        "placeholder": "Description",
                        "inputType": "text",
                        "required": false,
                        "displayProperty": "Editable",
                        "visible": true,
                        "renderingHints": {
                            "width": "twelve"
                        },
                        "index": 2,
                        "validation": [
                            {
                                "type": "regex",
                                "value": "^[a-zA-Z0-9\\s]*$",
                                "message": "Invalid Input"
                            },
                            {
                                "type": "max",
                                "value": "250",
                                "message": "Input is Exceded"
                            }
                        ]
                    }
                ]
            }
    }
}'

## Course

curl --location --request POST "https://${domain_name}/api/data/v1/form/create" \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${jwt_token}" \
--data-raw '{
	"request": {
		"type": "content",
		"subType": "course",
		"action": "create",
		"framework": "'${org}'",
		"rootOrgId": "'${org_id}'",
        "data": {
                "templateName": "defaultTemplate",
                "action": "create",
                "fields": [
                    {
                        "code": "name",
                        "dataType": "text",
                        "name": "Name",
                        "lable": "Name",
                        "description": "Name",
                        "editable": true,
                        "placeholder": "Name",
                        "inputType": "text",
                        "required": false,
                        "displayProperty": "Editable",
                        "visible": true,
                        "renderingHints": {
                            "width": "twelve"
                        },
                        "index": 1,
                        "validation": [
                            {
                                "type": "regex",
                                "value": "^[a-zA-Z0-9\\s]*$",
                                "message": "Invalid Input"
                            },
                            {
                                "type": "max",
                                "value": "75",
                                "message": "Input is Exceded"
                            }
                        ]
                    },
                    {
                        "code": "description",
                        "dataType": "text",
                        "name": "Description",
                        "lable": "Description",
                        "description": "description",
                        "editable": true,
                        "placeholder": "Description",
                        "inputType": "text",
                        "required": false,
                        "displayProperty": "Editable",
                        "visible": true,
                        "renderingHints": {
                            "width": "twelve"
                        },
                        "index": 2,
                        "validation": [
                            {
                                "type": "regex",
                                "value": "^[a-zA-Z0-9\\s]*$",
                                "message": "Invalid Input"
                            },
                            {
                                "type": "max",
                                "value": "250",
                                "message": "Input is Exceded"
                            }
                        ]
                    }
                ]
            }
    }
}'


#}}}
