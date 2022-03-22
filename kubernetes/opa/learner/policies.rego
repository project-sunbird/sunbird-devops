package policies

import data.common as super
import future.keywords.in

urls_to_action_mapping := {
  "/v1/user/tnc/accept": "acceptTermsAndCondition",
  "/v1/user/update": "updateUser",
  "/v1/user/assign/role": "assignRole",
  "/v2/user/assign/role": "assignRoleV2",
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
  roles := ["REPORT_VIEWER", "REPORT_ADMIN"]
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
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  input.parsed_body.request.organisationId in token_organisationids
}

assignRoleV2 {
  acls := ["assignRole"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_orgs := super.org_check(roles)

  # In the below code, we use sets and compare them
  # This can be done using arrays also
  # Take a look at the audience check (commented out) in common.rego which uses the array logic

  payload_orgs := {ids | ids := input.parsed_body.request.roles[_].scope[_].organisationId}
  matching_orgs := {orgs | some i; payload_orgs[i] in token_orgs; orgs := i}
  payload_orgs == matching_orgs
}

privateUserLookup {
  # This should be moved to a system token
  true
}

privateUserMigrate {
  # This should be moved to a system token
  true
}

privateUserRead {
  # This should be moved to a system token
  true
}