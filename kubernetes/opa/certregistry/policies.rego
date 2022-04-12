package policies

import data.common as super

urls_to_action_mapping := {   
  "/certs/v1/registry/download": "downloadRegCertificate",
  "/certs/v2/registry/download": "downloadRegCertificateV2",
  "/certs/v1/registry/search": "searchRegCertificate"
}

downloadRegCertificate {
  super.public_role_check
}

downloadRegCertificateV2 {
  super.public_role_check
}

searchRegCertificate {
  super.public_role_check
  recipient_ids := {id | id = input.parsed_body.request.query.bool.must[_].match_phrase["recipient.id"]}
  count(recipient_ids) == 1
  recipient_ids[super.userid] == super.userid
}