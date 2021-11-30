package main

import input.attributes.request.http as http_request

default allow = false

urls[keys] { urls_to_action_mapping[keys]}   

urls_to_action_mapping := {   
   "/collection/v4/import": "collectionImport",
   "/collection/v4/export": "collectionExport",
   "/content/v3/create": "createContent",
   "/content/v3/review": "submitContentForReview"
}

identified_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_action := urls_to_action_mapping[identified_url]

allow {
   data.policies[identified_action]
}
