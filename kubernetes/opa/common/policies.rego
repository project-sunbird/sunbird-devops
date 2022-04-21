package policies

import data.common as super
import future.keywords.in

urls_to_action_mapping := {
   "/url/allowed": "allow",
   "/url/not/allowed": "deny",
   "/public/role/check": "public_role_check",
   "/user/org/check": "user_and_org_check",
   "/internal/api/call": "is_an_internal_request"
}

allow = true

deny = false

public_role_check {
   super.public_role_check
}

user_and_org_check {
   acls := ["createContent"]
   roles := ["CONTENT_CREATOR"]
   super.acls_check(acls)
   token_organisationids := super.org_check(roles)
   input.parsed_body.request.content.createdBy == super.userid
   input.parsed_body.request.content.channel in token_organisationids
}

is_an_internal_request {
   super.is_an_internal_request  
}