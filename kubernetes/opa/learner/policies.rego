package policies

import data.common as super
import future.keywords.in
import input.attributes.request.http as http_request

urls_to_action_mapping := {
  "/v1/user/tnc/accept": "acceptTermsAndCondition",
  "/v1/user/update": "updateUser",
  "/v1/user/assign/role": "assignRole",
  "/v2/user/assign/role": "assignRoleV2",
  "/v1/user/read": "getUserProfile",
  "/v2/user/read": "getUserProfileV2",
  "/v3/user/read": "getUserProfileV3",
  "/v4/user/read": "getUserProfileV4",
  "/v5/user/read": "getUserProfileV5",
  "/v1/user/feed": "userFeed",
  "/v2/user/update": "updateUserV2",
  "/v3/user/update": "updateUserV3",
  "/v1/user/declarations": "updateUserDeclarations",
  "/v1/manageduser/create": "managedUserV1Create",
  "/v1/user/managed": "searchManagedUser",
  "/v1/user/consent/read": "readUserConsent",
  "/v1/user/consent/update": "updateUserConsent",
  "/v2/org/preferences/read": "readTenantPreferences",
  "/v2/org/preferences/create": "createTenantPreferences",
  "/v2/org/preferences/update": "updateTenantPreferences"
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
  super.public_role_check
  input.parsed_body.request.userId == super.userid
}

# Optional request.userId - https://project-sunbird.atlassian.net/browse/SB-29723
acceptTermsAndCondition {
  super.public_role_check
  not input.parsed_body.request.tncType
  not input.parsed_body.request.userId
}

updateUser {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
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

getUserProfile {
  super.public_role_check
  user_id := split(http_request.path, "/")[4]
  split(user_id, "?")[0] == super.userid
}

getUserProfileV2 {
  super.public_role_check
  user_id := split(http_request.path, "/")[4]
  split(user_id, "?")[0] == super.userid
}

getUserProfileV3 {
  super.public_role_check
  user_id := split(http_request.path, "/")[4]
  split(user_id, "?")[0] == super.userid
}

getUserProfileV4 {
  super.public_role_check
  user_id := split(http_request.path, "/")[4]
  split(user_id, "?")[0] == super.userid
}

getUserProfileV5 {
  super.public_role_check
  user_id := split(http_request.path, "/")[4]
  split(user_id, "?")[0] == super.userid
}

# Org admin is allowed to retrive any user info using the /v5/user/read endpoint
getUserProfileV5 {
  acls := ["getUserProfileV5"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

# Allow the API call when using ?withTokens=true as query param - https://project-sunbird.atlassian.net/browse/SB-29676
getUserProfileV5 {
  super.public_role_check
  contains(http_request.path, "?withTokens=true")
}

userFeed {
  super.public_role_check
  user_id := split(http_request.path, "/")[4]
  split(user_id, "?")[0] == super.userid
}

updateUserV2 {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
}

# Org admin is allowed to update any user info using the /v2/user/update endpoint
updateUserV2 {
  acls := ["updateUserV2"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

updateUserV3 {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
}

updateUserDeclarations {
  super.public_role_check
  payload_userids := {ids | ids := input.parsed_body.request.declarations[_].userId}
  count(payload_userids) == 1
  payload_userids[super.userid] == super.userid
}

# If for token exists, check request.managedBy matches for_token_parentid
managedUserV1Create {
  super.public_role_check
  input.parsed_body.request.managedBy == super.for_token_parentid
}

# If for token doesn't exist, check request.managedBy matches userid
managedUserV1Create {
  super.public_role_check
  input.parsed_body.request.managedBy == super.userid
}

# If for token exists, check userid in url matches for token parent id
searchManagedUser {
  super.public_role_check
  super.for_token_exists
  user_id := split(http_request.path, "/")[4]
  split(user_id, "?")[0] == super.for_token_parentid
}

# If for token doesn't exist, check userid in url matches the x-authenticated-user-token userid
searchManagedUser {
  super.public_role_check
  not super.for_token_exists
  user_id := split(http_request.path, "/")[4]
  split(user_id, "?")[0] == super.userid
}

readUserConsent {
  super.public_role_check
  input.parsed_body.request.consent.filters.userId == super.userid
}

# Org admin is allowed to read any user's consent using the /v1/user/consent/read endpoint
readUserConsent {
  acls := ["readUserConsent"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

updateUserConsent {
  super.public_role_check
  input.parsed_body.request.consent.userId == super.userid
}

readTenantPreferences {
  super.public_role_check
}

createTenantPreferences {
  acls := ["createTenantPreferences"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

updateTenantPreferences {
  acls := ["updateTenantPreferences"]
  roles := ["ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}