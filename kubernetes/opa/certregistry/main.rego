package main

import input.attributes.request.http as http_request

default allow = false

urls[keys] { urls_to_action_mapping[keys]}   

urls_to_action_mapping := {   
   "/certs/v1/registry/download": "downloadRegCertificate",
   "/certs/v2/registry/download": "downloadRegCertificateV2"
}

identified_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_action := urls_to_action_mapping[identified_url]

allow {
   data.policy[identified_action]
}
