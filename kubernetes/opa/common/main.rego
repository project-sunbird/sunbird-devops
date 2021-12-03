package main

import input.attributes.request.http as http_request
import data.policies as policy

default allow = false

urls[keys] { policy.urls_to_action_mapping[keys]}

identified_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_action := policy.urls_to_action_mapping[identified_url]

allow {
   data.policies[identified_action]
}