package main

import input.attributes.request.http as http_request

default allow = false

urls[keys] { urls_to_action_mapping[keys]}   

urls_to_action_mapping := {
   "/user/v1/tnc/accept": "acceptTermsAndCondition",
   "/user/v1/role/assign": "assignRole",
   "/user/v2/role/assign": "assignRoleV2",
   "/v1/user/update": "updateUser",
   "/private/user/v1/lookup": "privateUserLookup",
   "/private/user/v1/migrate": "privateUserMigrate",
   "/private/user/v1/read": "privateUserRead"
}

identified_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_action := urls_to_action_mapping[identified_url]

allow {
   data.policies[identified_action]
}
