package policies

import future.keywords.in
import input.attributes.request.http as http_request

federationId := "{{ core_vault_sunbird_keycloak_user_federation_provider_id }}"

ROLES := {
   "BOOK_REVIEWER": ["createLock", "publishContent"],
   "CONTENT_REVIEWER": ["createLock", "publishContent"],
   "FLAG_REVIEWER": ["publishContent"],
   "BOOK_CREATOR": ["copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview"],
   "CONTENT_CREATOR": ["copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview", "submitDataExhaustRequest"],
   "COURSE_CREATOR": ["updateBatch", "copyContent", "createContent", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview"],
   "COURSE_MENTOR": ["updateBatch", "submitDataExhaustRequest"],
   "PROGRAM_MANAGER": ["submitDataExhaustRequest"],
   "PROGRAM_DESIGNER": ["submitDataExhaustRequest"],
   "ORG_ADMIN": ["acceptTnc", "assignRole", "submitDataExhaustRequest"],
   "REPORT_VIEWER": ["acceptTnc"],
   "REPORT_ADMIN": ["submitDataExhaustRequest"],
   "PUBLIC": ["PUBLIC"]
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
  acls := ["acceptTnc"]
  input.parsed_body.request.tncType == "orgAdminTnc"
  xAuthUserToken.payload.roles[_].role == "ORG_ADMIN"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

acceptTermsAndCondition {
  acls := ["acceptTnc"]
  input.parsed_body.request.tncType == "reportViewerTnc"
  xAuthUserToken.payload.roles[_].role == "REPORT_VIEWER"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

acceptTermsAndCondition {
  input.parsed_body.request.tncType != "orgAdminTnc"
  input.parsed_body.request.tncType != "reportViewerTnc"
}

not acceptTermsAndCondition {
  input.parsed_body.request.tncType
}
 
assignRole {
  acls := ["assignRole"]
  xAuthUserToken.payload.roles[_].role == "ORG_ADMIN"
  some i; ROLES[token.payload.roles[i].role][_] == acls[_]
  xAuthUserToken.payload.roles[i].scope[_].organisationId == input.parsed_body.request.roles[_].scope[_].organisationId
}

updateUser {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[token.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

updateUser {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[token.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

assignRoleV2 {
  acls := ["assignRole"]
  xAuthUserToken.payload.roles[_].role == "ORG_ADMIN"
  some i; ROLES[token.payload.roles[i].role][_] == acls[_]
  tokenOrgs := { orgs | orgs = xAuthUserToken.payload.roles[i].scope[_].organisationId}
  payloadOrgs := { orgs | orgs = input.parsed_body.request.roles[_].scope[_].organisationId}
  # Union of sets
  tokenAndPayloadOrgs := tokenOrgs | payloadOrgs
  # All orgs in payload must be present in token orgs of org admin
  count(tokenAndPayloadOrgs) <= count(tokenOrgs)
}

privateUserLookup {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[token.payload.roles[_].role][_] == acls[_]
}

privateUserMigrate {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[token.payload.roles[_].role][_] == acls[_]

}

privateUserRead {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[token.payload.roles[_].role][_] == acls[_]
}