package policies

import data.common as super
import future.keywords.in
import input.attributes.request.http as http_request

accept := http_request.headers["Accept"]


urls_to_action_mapping := {   
  "/api/v1": "rcCertificate"
}

allowed_accept_headers := ["image/svg+xml", "application/json", "application/vc+ld+json"]

# Open APIs to query some data - User token not required
rcCertificate {
  accept in allowed_accept_headers
  http_request.method == "GET"
  accept in ["application/json", "application/vc+ld+json"]
}

# Download the user certificate - User token required
rcCertificate {
  accept in allowed_accept_headers
  http_request.method == "GET"
  accept == "image/svg+xml"
  super.public_role_check
}

# Search certificate operation - User token required
# Mobile app payload
rcCertificate {
  endswith(http_request.path, "/search")
  accept in allowed_accept_headers
  http_request.method == ["POST"]
  super.public_role_check
  input.parsed_body.filters["recipient.id"].eq == super.userid
}

# Portal payload
rcCertificate {
  endswith(http_request.path, "/search")
  accept in allowed_accept_headers
  http_request.method == ["POST"]
  super.public_role_check
  input.parsed_body.filters.recipient.id.eq == super.userid
}

# Delete certificate operation - User token required
rcCertificate {
  accept in allowed_accept_headers
  http_request.method == ["DELETE"]
  super.public_role_check
}