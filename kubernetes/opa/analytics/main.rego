package main

import input.attributes.request.http as http_request

default allow = false

urls[keys] { urls_to_action_mapping[keys]}   

urls_to_action_mapping := {   
   "/dataset/v1/request/read": "getDataExhaustRequest",
   "/dataset/v1/request/list": "listDataExhaustRequest",
   "/dataset/v1/request/submit": "submitDataExhaustRequest"
}

identified_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_action := urls_to_action_mapping[identified_url]

allow {
   data.policy[identified_action]
}
