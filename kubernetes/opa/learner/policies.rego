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
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  input.parsed_body.request.organisationId in token_organisationids
}

assignRoleV2 {
  acls := ["assignRole"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  payload_organisationids := [ids | ids = input.parsed_body.request.roles[_].scope[_].organisationId]
  count_of_matching_orgs_indices := [orgs | some i; payload_organisationids[i] in token_organisationids; orgs = i]
  count(count_of_matching_orgs_indices) == count(payload_organisationids)
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