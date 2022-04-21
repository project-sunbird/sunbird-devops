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


# We need to ensure we choose the longest match of an url, so we use the max(array) function
# Example:
#  http_request.path = /asset/v4/upload/url/do_11319479631000371211
# The above url will match two url in content service policy
# - /asset/v4/upload
# - /asset/v4/upload/url
# This will lead to a rego error since we cannot have two different outputs on one input
# eval_conflict_error: complete rules must not produce multiple outputs
# So we first get a regex of the urls from policy and request path
# Then we check if the request path starts with the policy url
# If we get mutliple matches as explained above, then we can guarantee to consider the longest match
# The shorter url will not matche multiple urls
# Example: /asset/v4/upload/do_11319479631000371211 will match only /asset/v4/upload and not /asset/v4/upload/url

regex_urls := [url | url := regex.find_n(urls[_], http_request.path, 1)[0]]
matching_urls := [url | some i; startswith(http_request.path, regex_urls[i]); url := regex_urls[i]]
identified_url := max(matching_urls)
identified_action := policy.urls_to_action_mapping[identified_url]

# Desktop app is not sending x-authenticated-for header due to which managed user flow is breaking
# This is a temporary fix till the desktop app issue is fixed
skipped_consumers := {{ kong_desktop_device_consumer_names_for_opa }}
x_consumer_username := http_request.headers["x-consumer-username"]
check_if_consumer_is_skipped {
   x_consumer_username in skipped_consumers
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
