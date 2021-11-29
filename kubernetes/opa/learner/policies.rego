package policies

import input.attributes.request.http as http_request

federationId := "{{ core_vault_sunbird_keycloak_user_federation_provider_id }}"

ROLES := {
   "BOOK_CREATOR": ["contentCreate", "contentAccess", "contentAdmin", "contentUpdate", "dataAccess"],
   "BOOK_REVIEWER": ["contentCreate", "contentAdmin", "dataAccess"],
   "CONTENT_CREATOR": ["contentCreate", "contentAccess", "contentAdmin", "contentUpdate", "dataAccess", "dataCreate"],
   "COURSE_CREATOR": ["contentCreate", "contentAccess", "contentAdmin", "contentUpdate", "courseUpdate", "dataAccess"],
   "COURSE_MENTOR": ["courseUpdate", "dataAccess", "dataCreate"],
   "CONTENT_REVIEWER": ["contentCreate", "contentAdmin", "dataAccess"],
   "FLAG_REVIEWER": ["appAccess", "contentAdmin", "dataAccess"],
   "PROGRAM_MANAGER": ["dataCreate", "dataAccess"],
   "PROGRAM_DESIGNER": ["dataCreate", "dataAccess"],
   "ORG_ADMIN": ["userAdmin", "appAccess", "dataAccess", "dataCreate"],
   "REPORT_VIEWER": ["appAccess", "dataAccess"],
   "REPORT_ADMIN": ["dataCreate", "dataAccess"],
   "PUBLIC": ["PUBLIC", "dataAccess"]
}

xAuthUserToken := {"payload": payload} {
  encoded := http_request.headers["x-authenticated-user-token"]
  [_, payload, _] := io.jwt.decode(encoded)
}

xAuthForToken := {"payload": payload} {
  encoded := http_request.headers["x-authenticated-for"]
  [_, payload, _] := io.jwt.decode(encoded)
}

acceptTermsAndCondition {
  acls := ["appAccess"]
  input.parsed_body.request.tncType == "orgAdminTnc"
  xAuthUserToken.payload.roles[_].role == "ORG_ADMIN"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

acceptTermsAndCondition {
  acls := ["appAccess"]
  input.parsed_body.request.tncType == "reportViewerTnc"
  xAuthUserToken.payload.roles[_].role == "REPORT_VIEWER"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

acceptTermsAndCondition {
  acls := ["appAccess"]
  input.parsed_body.request.tncType != "orgAdminTnc"
  input.parsed_body.request.tncType != "reportViewerTnc"
}

not acceptTermsAndCondition {
  acls := ["appAccess"]
  input.parsed_body.request.tncType
}
 
assignRole {
  acls := ["userAdmin"]
  some i; ROLES[token.payload.roles[i].role][_] == acls[_]
  xAuthUserToken.payload.roles[i].scope[_].organisationId == input.parsed_body.request.roles[_].scope[_].organisationId
}

updateUser {
  acls := ["userUpdate"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

updateUser {
  acls := ["userUpdate"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

assignRoleV2 {
  acls := ["userAdmin"]
  some i; ROLES[token.payload.roles[i].role][_] == acls[_]
  tokenOrgs := { orgs | orgs = xAuthUserToken.payload.roles[i].scope[_].organisationId}
  payloadOrgs := { orgs | orgs = input.parsed_body.request.roles[_].scope[_].organisationId}
  # Union of sets
  tokenAndPayloadOrgs := tokenOrgs | payloadOrgs
  # All orgs in payload must be present in token orgs of org admin
  count(tokenAndPayloadOrgs) <= count(tokenOrgs)
}

privateUserLookup {
  acls := ["privateUserLookup"]
}

privateUserMigrate {
  acls := ["privateUserMigrate"]
}

privateUserRead {
  acls := ["privateUserRead"]
}