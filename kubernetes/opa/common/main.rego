package main

import input.attributes.request.http as http_request
import data.policies as policy
import future.keywords.in

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

# Desktop app is not sending x-authenticated-for header due to which managed user flow is breaking
# This is a temporary fix till the desktop app issue is fixed

allow {
   http_request.headers["x-consumer-username"] in {{ kong_desktop_device_consumer_names_for_opa }}
}