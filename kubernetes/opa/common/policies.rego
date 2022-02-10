package policies

import data.common as super
import future.keywords.in

urls_to_action_mapping := {   
   "/url/allowed": "allow",
   "/url/not/allowed": "deny",
   "/public/role/check": "public_role_check",
   "/org/check": "org_check"
}

allow = true

deny = false

public_role_check {
   super.public_role_check
}

org_check {
   acls := ["createContent"]
   roles := ["CONTENT_CREATOR"]
   super.acls_check(acls)
   token_organisationids := super.org_check(roles)
   input.parsed_body.request.content.channel in token_organisationids
}