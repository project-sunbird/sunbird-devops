package policies

import data.common as super
import future.keywords.in
import input.attributes.request.http as http_request

accept := http_request.headers["accept"]

urls_to_action_mapping := {
  # Change the URL as below in 4.9.0 as we have implemeted longest URL match
  # "/api/v1/TrainingCertificate": "createGetDeleteRCCertificate",
  # "/api/v1/TrainingCertificate/search": "searchRCCertificate",
  "/api/v1/TrainingCertificate": "rcCertificate",
  "/api/v1/PublicKey": "getRCPublicKey"
}

# Create or Delete certificate API - Invoked by flink jobs
# createGetDeleteRCCertificate
rcCertificate {
  http_request.method in ["POST", "DELETE"]
  not endswith(http_request.path, "/search")
  not endswith(http_request.path, "/PublicKey/search")
  super.is_an_internal_request
}

# Open APIs to query some certificate data - User token not required
# createGetDeleteRCCertificate
rcCertificate {
  http_request.method == "GET"
  accept in ["application/json", "application/vc+ld+json"]
}

# Download the user certificate - User token required
# createGetDeleteRCCertificate
rcCertificate {
  http_request.method == "GET"
  accept == "image/svg+xml"
  super.public_role_check
}

# Search certificate operation - User token required
# searchRCCertificate
# Mobile app payload
rcCertificate {
  http_request.method == "POST"
  endswith(http_request.path, "/search")
  not endswith(http_request.path, "/PublicKey/search")
  super.public_role_check
  input.parsed_body.filters["recipient.id"].eq == super.userid
}

# Portal payload
# searchRCCertificate
rcCertificate {
  http_request.method == "POST"
  endswith(http_request.path, "/search")
  not endswith(http_request.path, "/PublicKey/search")
  super.public_role_check
  input.parsed_body.filters.recipient.id.eq == super.userid
}

# Retrieve public key API
getRCPublicKey {
  http_request.method == "POST"
}