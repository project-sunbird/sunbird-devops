# Note this file is a hard link
# A change here will change in all directories where this link resides
# Opa issue - https://github.com/open-policy-agent/opa/issues/4335

package main

import input.attributes.request.http as http_request
import data.policies as policy
import future.keywords.in

default allow = {
  "allowed": false,
  "headers": {"x-request-allowed": "no"},
  "body": "You do not have permission to perform this operation",
  "http_status": 403
}

urls[keys] { policy.urls_to_action_mapping[keys]}
matching_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_url := matching_url {startswith(http_request.path, matching_url)}
identified_action := policy.urls_to_action_mapping[identified_url]

# Desktop app is not sending x-authenticated-for header due to which managed user flow is breaking
# This is a temporary fix till the desktop app issue is fixed
skipped_consumers := {{ kong_desktop_device_consumer_names_for_opa }}
check_if_consumer_is_skipped {
   http_request.headers["x-consumer-username"] in skipped_consumers
}

allow = status {
   not check_if_consumer_is_skipped
   policy[identified_action]
   status := {
      "allowed": true,
      "headers": {"x-request-allowed": "yes"},
      "body": "OPA Checks Passed",
      "http_status": 200
   }
}

allow = status {
   not identified_action
   status := {
      "allowed": true,
      "headers": {"x-request-allowed": "yes"},
      "body": "OPA Checks Skipped",
      "http_status": 200
   }
}

# Desktop app is not sending x-authenticated-for header due to which managed user flow is breaking
# This is a temporary fix till the desktop app issue is fixed
allow = status {
   check_if_consumer_is_skipped
   status := {
      "allowed": true,
      "headers": {"x-request-allowed": "yes"},
      "body": "OPA Checks Skipped",
      "http_status": 200
   }
}
