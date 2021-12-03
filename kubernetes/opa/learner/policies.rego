package policies

import data.common as super
import future.keywords.in

urls_to_action_mapping := {
   "/v1/user/tnc/accept": "acceptTermsAndCondition",
   "/v1/user/assign/role": "assignRole",
   "/v2/user/assign/role": "assignRoleV2",
   "/v1/user/update": "updateUser",
   "/private/user/v1/lookup": "privateUserLookup",
   "/private/user/v1/migrate": "privateUserMigrate",
   "/private/user/v1/read": "privateUserRead"
}

acceptTermsAndCondition {
  acls := ["acceptTnc"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
  "orgAdminTnc" == input.parsed_body.request.tncType
}

acceptTermsAndCondition {
  acls := ["acceptTnc"]
  roles := ["REPORT_VIEWER"]
  super.acls_check(acls)
  super.role_check(roles)
  "reportViewerTnc" == input.parsed_body.request.tncType
}

acceptTermsAndCondition {
  not input.parsed_body.request.tncType in ["orgAdminTnc", "reportViewerTnc"]
}

acceptTermsAndCondition {
  not input.parsed_body.request.tncType
}

updateUser {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
}

assignRole {
  acls := ["assignRole"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
  token_organisationids := super.org_check(roles)
  input.parsed_body.request.organisationId in token_organisationids
}

assignRoleV2 {
  acls := ["assignRole"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
  token_organisationids := super.org_check(roles)
  payload_organisationids := { ids | ids = input.parsed_body.request.roles[_].scope[_].organisationId}
  # Union of sets
  token_and_payload_orgs_union := token_organisationids | payload_organisationids
  # All orgs in payload must be present in token scope under ORG_ADMIN role. So the count of unique orgs in payload will always be less than or equal to count of unique orgs in token under ORG_ADMIN role
  count(token_organisationids) <= count(payload_organisationids)
}

privateUserLookup {
  super.public_role_check
}

privateUserMigrate {
  super.public_role_check
}

privateUserRead {
  super.public_role_check
}