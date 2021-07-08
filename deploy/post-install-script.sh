#!/bin/bash

set -euo pipefail

proto=$1
domain_name=$2
core_vault_sunbird_api_auth_token=$3
private_ingressgateway_ip=$4
learningservice_ip=$5
core_vault_sunbird_sso_client_secret=$6
core_vault_sunbird_google_captcha_site_key_portal=$7
sunbird_azure_public_storage_account_name=$8
cassandra=$9
knowledge_platform_tag=${10}
forms=https://sunbirdpublic.blob.core.windows.net/installation/forms.csv
x_authenticated_token=""
organisation=""
creator=""
reviewer=""
orgadmin=""

cassandra_forms(){
    # Import the forms into cassandra
    echo -e "\e[0;32m${bold}Install cqlsh ${normal}"
    pip install -U cqlsh
    printf "\n"
    echo -e "\e[0;32m${bold}Download forms ${normal}"
    wget "$forms"
    printf "\n"
    echo -e "\e[0;32m${bold}Import forms ${normal}"
    /var/lib/jenkins/.local/bin/cqlsh $cassandra 9042 -e "COPY qmzbm_form_service.form_data FROM 'forms.csv' WITH HEADER = true AND CHUNKSIZE = 1;"
    rm forms.csv
}

get_x_authenticated_token(){
    # Keycloak access token
    printf "\n\n"
    echo -e "\e[0;32m${bold}Get x-authenticated-user-token${normal}"
    x_authenticated_token=$(curl -sS -XPOST "${proto}://${domain_name}/auth/realms/sunbird/protocol/openid-connect/token" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'client_id=lms' \
    --data-urlencode "client_secret=${core_vault_sunbird_sso_client_secret}" \
    --data-urlencode 'grant_type=client_credentials' | jq -r .access_token)
    echo "x_authenticated_token: ${x_authenticated_token}"
}

create_organisation(){
    # Create one organisation as default
    printf "\n\n"
    echo -e "\e[0;32m${bold}Creating default organisation ${normal}"
    organisation=$(curl -sS -XPOST "${proto}://${domain_name}/api/org/v1/create" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
           "orgName":"Sunbird Org",
           "description":"Default Organisation for Sunbird",
           "isRootOrg": true,
           "channel": "sunbird",
           "organisationType": "board",
           "isTenant": true
       }
    }' | jq -r .result.organisationId)
    echo "organisationId: ${organisation}"
}

create_users(){
    # Create 3 users - Content Creator, Content Reviewer, Org Admin 
    printf "\n\n"
    echo -e "\e[0;32m${bold}Creating default users for Content Creator, Content Reviewer and Org Admin ${normal}"
    creator=$(curl -sS -XPOST "${proto}://${domain_name}/api/user/v1/signup" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "firstName": "creator",
  		   "lastName": "creator",
  		   "password": "Pass@123",
  		   "phone": "9999911111",
  		   "userName": "creator",
  		   "channel": "sunbird",
  		   "phoneVerified": true
       }
    }' | jq -r .result.userId)
    echo "creator userid: ${creator}"

    reviewer=$(curl -sS -XPOST "${proto}://${domain_name}/api/user/v1/signup" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "firstName": "reviewer",
  		   "lastName": "reviewer",
  		   "password": "Pass@123",
  		   "phone": "9999911112",
  		   "userName": "reviewer",
  		   "channel": "sunbird",
  		   "phoneVerified": true
       }
    }' | jq -r .result.userId)
    echo "reviewer userid: ${reviewer}"

    orgadmin=$(curl -sS -XPOST "${proto}://${domain_name}/api/user/v1/signup" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "firstName": "orgadmin",
  		   "lastName": "orgadmin",
  		   "password": "Pass@123",
  		   "phone": "9999911113",
  		   "userName": "orgadmin",
  		   "channel": "sunbird",
  		   "phoneVerified": true
       }
    }' | jq -r .result.userId)
    echo "orgadmin userid: ${orgadmin}"
}

assign_roles(){
    # Assign roles to user - Content Creator, Content Reviewer, Org Admin
    printf "\n\n"
    echo -e "\e[0;32m${bold}Assign roles for default users -  Content Creator, Content Reviewer and Org Admin ${normal}"
    curl -sS -XPOST "${proto}://${domain_name}/api/user/v1/role/assign" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "organisationId": "'"${organisation}"'", 
		   "userId": "'"${creator}"'",
		   "roles": ["CONTENT_CREATOR"]
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/user/v1/role/assign" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "organisationId": "'"${organisation}"'",
		   "userId": "'"${reviewer}"'",
		   "roles": ["CONTENT_REVIEWER"]
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/user/v1/role/assign" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "organisationId": "'"${organisation}"'",
		   "userId": "'"${orgadmin}"'",
		   "roles": ["ORG_ADMIN"]
       }
    }'
}

create_master_categories(){
    # Create the 5 master categories
    printf "\n\n"
    echo -e "\e[0;32m${bold}Creating master categories for board, medium, subject, gradeLevel, topic ${normal}"
    curl -XPOST "http://${learningservice_ip}:8080/learning-service/framework/v3/category/master/create" -H 'Content-Type: application/json' -H "X-Channel-Id: ${organisation}" --data-raw '{"request": {"category": {"name": "board","code": "board"}}}'
    curl -XPOST "http://${learningservice_ip}:8080/learning-service/framework/v3/category/master/create" -H 'Content-Type: application/json' -H "X-Channel-Id: ${organisation}" --data-raw '{"request": {"category": {"name": "medium","code": "medium"}}}'
    curl -XPOST "http://${learningservice_ip}:8080/learning-service/framework/v3/category/master/create" -H 'Content-Type: application/json' -H "X-Channel-Id: ${organisation}" --data-raw '{"request": {"category": {"name": "subject","code": "subject"}}}'
    curl -XPOST "http://${learningservice_ip}:8080/learning-service/framework/v3/category/master/create" -H 'Content-Type: application/json' -H "X-Channel-Id: ${organisation}" --data-raw '{"request": {"category": {"name": "gradeLevel","code": "gradeLevel"}}}'
    curl -XPOST "http://${learningservice_ip}:8080/learning-service/framework/v3/category/master/create" -H 'Content-Type: application/json' -H "X-Channel-Id: ${organisation}" --data-raw '{"request": {"category": {"name": "topic","code": "topic"}}}'
}

create_default_licenses(){
    # Create default licenses in the system
    printf "\n\n"
    echo -e "\e[0;32m${bold}Create default licenses ${normal}"
    curl -XPOST "http://${private_ingressgateway_ip}/content/license/v3/create" -H 'Content-Type: application/json' \
    -d '{
       "request":{
           "license":{
               "name": "CC BY-NC-SA 4.0",
               "description": "This license is Creative Commons Attribution-NonCommercial-ShareAlike",
               "url": "https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode"
           }
        }
    }'

    curl -XPOST "http://${private_ingressgateway_ip}/content/license/v3/create" -H 'Content-Type: application/json' \
    -d '{
       "request":{
           "license":{
               "name": "CC BY-NC 4.0",
               "description": "This license is Creative Commons Attribution-NonCommercial",
               "url": "https://creativecommons.org/licenses/by-nc/4.0/legalcode"
           }
        }
    }'

    curl -XPOST "http://${private_ingressgateway_ip}/content/license/v3/create" -H 'Content-Type: application/json' \
    -d '{
       "request":{
           "license":{
               "name": "CC BY-SA 4.0",
               "description": "This license is Creative Commons Attribution-ShareAlike",
               "url": "https://creativecommons.org/licenses/by-sa/4.0/legalcode"
           }
        }
    }'

    curl -XPOST "http://${private_ingressgateway_ip}/content/license/v3/create" -H 'Content-Type: application/json' \
    -d '{
       "request":{
           "license":{
               "name": "CC BY 4.0",
               "description": "This is the standard license of any Youtube content",
               "url": "https://creativecommons.org/licenses/by/4.0/legalcode"
           }
        }
    }'

    curl -XPOST "http://${private_ingressgateway_ip}/content/license/v3/create" -H 'Content-Type: application/json' \
    -d '{
       "request":{
           "license":{
               "name": "Standard YouTube License",
               "description": "This license is Creative Commons Attribution-NonCommercial-ShareAlike",
               "url": "https://www.youtube.com/"
           }
        }
    }'
}

create_default_channel_license(){
    # Choosing a random license from which was created in create_default_licenses()
    printf "\n\n"
    echo -e "\e[0;32m${bold}Assign a random default license for the organisation ${normal}"
    curl -XPATCH "http://${learningservice_ip}:8080/learning-service/channel/v3/update/${organisation}" -H 'Content-Type: application/json' \
    -d '{
       "request":{
           "channel":{
               "defaultLicense":"Standard YouTube License"
           }
        }
    }'
}

create_other_categories(){
    # Create other category schema
    printf "\n\n"
    echo -e "\e[0;32m${bold}Create other categories ${normal}"
    git clone https://github.com/project-sunbird/knowledge-platform.git -b ${knowledge_platform_tag}
    cd knowledge-platform/definition-scripts
    sed -i "s#{{host}}#http://${private_ingressgateway_ip}/taxonomy#g" *
    sed -i "s#curl#curl -sS#g" *
    while read -r line; do printf "\n\n" >> /tmp/all_category_create.sh && cat $line >> /tmp/all_category_create.sh; done <<< $(ls)
    bash -x /tmp/all_category_create.sh
    rm /tmp/all_category_create.sh
}

system_settings(){
    # System settings to insert into cassandra
    printf "\n\n"
    echo -e "\e[0;32m${bold}Initialize the system settings table ${normal}"
    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "custodianOrgId",
		   "field": "custodianOrgId",
		   "value": "'"${organisation}"'"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "custodianOrgChannel",
		   "field": "custodianOrgChannel",
		   "value": "sunbird"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "courseFrameworkId",
		   "field": "courseFrameworkId",
		   "value": "TPD"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "sunbird",
		   "field": "sunbird",
		   "value": "{\"helpCenterLink\":\"'${proto}':\/\/'${domain_name}'\/faq\",\"helpdeskEmail\":\"support@'${domain_name}'\"}"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "googleReCaptcha",
		   "field": "googleReCaptcha",
		   "value": "{\"key\":\"'${core_vault_sunbird_google_captcha_site_key_portal}'\", \"isEnabled\":true}"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "tncConfig",
		   "field": "tncConfig",
		   "value": "{\"latestVersion\":\"latest\",\"latest\":{\"url\":\"'${proto}':\/\/'${sunbird_azure_public_storage_account_name}'.blob.core.windows.net\/terms-and-conditions\/terms-and-conditions-v9.html#termsOfUse\"}}"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "orgAdminTnc",
		   "field": "orgAdminTnc",
		   "value": "{\"latestVersion\":\"latest\",\"latest\":{\"url\":\"'${proto}':\/\/'${sunbird_azure_public_storage_account_name}'.blob.core.windows.net\/terms-and-conditions\/terms-and-conditions-v9.html#administratorGuidelines\"}}"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "groupsTnc",
		   "field": "groupsTnc",
		   "value": "{\"latestVersion\":\"latest\",\"latest\":{\"url\":\"'${proto}':\/\/'${sunbird_azure_public_storage_account_name}'.blob.core.windows.net\/terms-and-conditions\/terms-and-conditions-v9.html#groupGuidelines\"}}"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "portalFaqURL",
		   "field": "portalFaqURL",
		   "value": "https://'${sunbird_azure_public_storage_account_name}'.blob.core.windows.net/public/portal-faq/resources/res"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		   "id": "ssoCourseSection",
		   "field": "ssoCourseSection",
		   "value": "'"${organisation}"'"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		"id": "userProfileConfig",
        "field": "userProfileConfig",
        "value": "{\"fields\":[\"firstName\",\"lastName\",\"profileSummary\",\"avatar\",\"countryCode\",\"dob\",\"email\",\"gender\",\"grade\",\"language\",\"location\",\"phone\",\"subject\",\"userName\",\"webPages\",\"jobProfile\",\"address\",\"education\",\"skills\",\"badgeAssertions\"],\"publicFields\":[\"firstName\",\"lastName\",\"profileSummary\",\"userName\"],\"privateFields\":[\"email\",\"phone\"],\"csv\":{\"supportedColumns\":{\"NAME\":\"firstName\",\"MOBILE PHONE\":\"phone\",\"EMAIL\":\"email\",\"SCHOOL ID\":\"orgId\",\"USER_TYPE\":\"userType\",\"ROLES\":\"roles\",\"USER ID\":\"userId\",\"SCHOOL EXTERNAL ID\":\"orgExternalId\"},\"outputColumns\":{\"userId\":\"USER ID\",\"firstName\":\"NAME\",\"phone\":\"MOBILE PHONE\",\"email\":\"EMAIL\",\"orgId\":\"SCHOOL ID\",\"orgName\":\"SCHOOL NAME\",\"userType\":\"USER_TYPE\",\"orgExternalId\":\"SCHOOL EXTERNAL ID\"},\"outputColumnsOrder\":[\"userId\",\"firstName\",\"phone\",\"email\",\"organisationId\",\"orgName\",\"userType\",\"orgExternalId\"],\"mandatoryColumns\":[\"firstName\",\"userType\",\"roles\"]},\"read\":{\"excludedFields\":[\"avatar\",\"jobProfile\",\"address\",\"education\",\"webPages\",\"skills\"]},\"framework\":{\"fields\":[\"board\",\"gradeLevel\",\"medium\",\"subject\",\"id\"],\"mandatoryFields\":[\"id\"]}}"
       }
    }'

    curl -sS -XPOST "${proto}://${domain_name}/api/data/v1/system/settings/set" -H 'Accept: application/json' -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request":{
  		"id": "orgProfileConfig",
        "field": "orgProfileConfig",
        "value": "{\"csv\":{\"supportedColumns\":{\"SCHOOL NAME\":\"orgName\",\"BLOCK CODE\":\"locationCode\",\"STATUS\":\"status\",\"SCHOOL ID\":\"organisationId\",\"EXTERNAL ID\":\"externalId\",\"DESCRIPTION\":\"description\"}, \"outputColumns\": {\"organisationId\":\"SCHOOL ID\",\"orgName\":\"SCHOOL NAME\",\"locationCode\":\"BLOCK CODE\",\"locationName\":\"BLOCK NAME\",\"externalId\":\"EXTERNAL ID\"}, \"outputColumnsOrder\":[\"organisationId\",\"orgName\",\"locationCode\", \"locationName\",\"externalId\"],\"mandatoryColumns\":[\"orgName\",\"locationCode\",\"status\"]}}"
       }
    }'
}

create_framework(){
    # Create the default NCF framework
    printf "\n\n"
    echo -e "\e[0;32m${bold}Create default NCF framework ${normal}"
    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
      "request": 
      {
        "framework": 
        {
          "name": "NCF",
          "description": "NCF Framework",
          "code": "NCF",
          "channels": [{"identifier": "'"${organisation}"'"}]
        }
      }
    }'
}

create_framework_categories(){
    # Create framework categories
    printf "\n\n"
    echo -e "\e[0;32m${bold}Create framework categories ${normal}"
    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create?framework=NCF" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "category": {
           "name": "Board",
           "code": "board"
         }
       }
    }'

    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create?framework=NCF" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "category": {
           "name": "Medium",
           "code": "medium"
         }
       }
    }'

    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create?framework=NCF" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "category": {
           "name": "Subject",
           "code": "subject"
         }
       }
    }'

    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create?framework=NCF" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "category": {
           "name": "GradeLevel",
           "code": "gradeLevel"
         }
       }
    }'
}

create_framework_terms(){
    # Create framework terms
    printf "\n\n"
    echo -e "\e[0;32m${bold}Create framework terms ${normal}"
    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create?framework=NCF&category=board" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "term": {
           "name": "Default Board",
           "code": "defaultboard"
         }
       }
    }'

    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create?framework=NCF&category=medium" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "term": {
           "name": "English",
           "code": "english"
         }
       }
    }'

    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create?framework=NCF&category=subject" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "term": {
           "name": "English",
           "code": "english"
         }
       }
    }'

    curl -XPOST "${proto}://${domain_name}/api/framework/v1/create?framework=NCF&category=gradeLevel" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "term": {
           "name": "Class 1",
           "code": "class1"
         }
       }
    }'
}

publish_framework(){
    # Publish the framework
    printf "\n\n"
    echo -e "\e[0;32m${bold}Publish framework ${normal}"
    curl -XPOST "${proto}://${domain_name}/api/framework/v1/publish/NCF" -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -H "X-Channel-Id: ${organisation}" \
    -d '{}'
}

tenant_preference(){
    # Create tenant certificate and user preference
    printf "\n\n"
    echo -e "\e[0;32m${bold}Create tenant certificate and user preference ${normal}"
    curl -XPOST "${proto}://${domain_name}/api/org/v2/preferences/create" -H 'Content-Type: application/json' -H 'accept: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "orgId": "'"${organisation}"'",
         "key": "certRules",
         "data": {
             "templateName": "certRules",
             "action": "save",
             "fields": [
               {
                 "code": "certTypes",
                 "dataType": "text",
                 "name": "certTypes",
                 "label": "Certificate type",
                 "description": "Select certificate",
                 "editable": true,
                 "inputType": "select",
                 "required": true,
                 "displayProperty": "Editable",
                 "visible": true,
                 "renderingHints": {
                   "fieldColumnWidth": "twelve"
                 },
                 "range": [
                   {
                     "name": "Completion certificate",
                     "value": {
                       "enrollment": {
                         "status": 2
                       }
                     }
                   },
                   {
                     "name": "Merit certificate",
                     "value": {
                       "score": "= 100"
                     }
                   }
                 ],
                 "index": 1
               },
               {
                 "code": "issueTo",
                 "dataType": "text",
                 "name": "issueTo",
                 "label": "Issue certificate to",
                 "description": "Select",
                 "editable": true,
                 "inputType": "select",
                 "required": true,
                 "displayProperty": "Editable",
                 "visible": true,
                 "renderingHints": {
                   "fieldColumnWidth": "twelve"
                 },
                 "range": [
                   {
                     "name": "All",
                     "value": {
                       "user": {
                         "rootid": ""
                       }
                     }
                   }
                 ],
                 "index": 2
               }
             ]
         }
       }
    }'
}

create_location(){
    # Create default location
    printf "\n\n"
    echo -e "\e[0;32m${bold}Create a default location ${normal}"
    curl -XPOST "${proto}://${domain_name}/api/data/v1/location/create" -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "code": "KA",
         "name": "Karnataka",
         "type": "state"
       }
    }'
    
    curl -XPOST "${proto}://${domain_name}/api/data/v1/location/create" -H 'Content-Type: application/json' \
    -H "X-Authenticated-User-Token: ${x_authenticated_token}" \
    -H "Authorization: Bearer ${core_vault_sunbird_api_auth_token}" \
    -d '{
       "request": {
         "code": "BLRURBAN",
         "name": "BENGALURU URBAN",
         "type": "district",
         "parentCode": "KA"
       }
    }'
}

bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\e[0;32m${bold}User provided inputs ${normal}"
printf "\n"
echo -e "\e[0;90m${bold}proto: $proto ${normal}"
echo -e "\e[0;90m${bold}domain_name: $domain_name ${normal}"
echo -e "\e[0;90m${bold}core_vault_sunbird_api_auth_token: $core_vault_sunbird_api_auth_token ${normal}"
echo -e "\e[0;90m${bold}private_ingressgateway_ip: $private_ingressgateway_ip ${normal}"
echo -e "\e[0;90m${bold}learningservice_ip: $learningservice_ip ${normal}"
echo -e "\e[0;90m${bold}core_vault_sunbird_sso_client_secret: $core_vault_sunbird_sso_client_secret ${normal}"
echo -e "\e[0;90m${bold}core_vault_sunbird_google_captcha_site_key_portal: $core_vault_sunbird_google_captcha_site_key_portal ${normal}"
echo -e "\e[0;90m${bold}sunbird_azure_public_storage_account_name: $sunbird_azure_public_storage_account_name ${normal}"
echo -e "\e[0;90m${bold}cassandra-1: $cassandra ${normal}"
echo -e "\e[0;90m${bold}knowledge-platform-tag: $knowledge_platform_tag ${normal}"
printf "\n\n"

cassandra_forms
get_x_authenticated_token
create_organisation
create_users
assign_roles
create_master_categories
create_default_licenses
create_default_channel_license
create_other_categories
system_settings
create_framework
create_framework_categories
create_framework_terms
publish_framework
tenant_preference
create_location

printf "\n\n"
echo -e "\e[0;31m${bold}Please verify all the API calls are successful. If there are any failures, check the script / output and fix the issues${normal}"

printf "\n\n"
echo -e "\e[0;31m${bold}All the API's must be successful to ensure Sunbird works as expected! ${normal}"

printf "\n\n"
echo -e "\e[0;32m${bold}If all the API's are succcessful, you can login to Sunbird using the username and password created above ${normal}"

printf "\n\n"
echo -e "\e[0;32m${bold}If you need more info on the API, refer to Sunbird API documentation ${normal}"
