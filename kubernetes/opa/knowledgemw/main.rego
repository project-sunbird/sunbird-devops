package main

import input.attributes.request.http as http_request

default allow = false

urls[keys] { urls_to_action_mapping[keys]}   

urls_to_action_mapping := {   
   "/content/v1/copy": "copyContent",
   "/content/v1/create": "createContent",
   "/lock/v1/create": "createLock",
   "/content/v1/publish": "publishContent",
   "/content/v1/collaborator/update": "updateCollaborators"
}

identified_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_action := urls_to_action_mapping[identified_url]

allow {
   data.policy[identified_action]
}
