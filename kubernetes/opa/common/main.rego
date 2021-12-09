package main

import input.attributes.request.http as http_request
import data.policies as policy

default allow = {
  "allowed": false,
  "headers": {"X-Request-Allowed": "no"},
  "body": "You do not have permission to perform this operation",
  "http_status": 403
}

urls[keys] { policy.urls_to_action_mapping[keys]}

matching_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_url := matching_url {startswith(http_request.path, matching_url)}
identified_action := policy.urls_to_action_mapping[identified_url]

allow {
   data.policies[identified_action]
}

allow {
   not identified_action
}