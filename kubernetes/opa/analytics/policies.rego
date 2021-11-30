package policies

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

getDataExhaustRequest {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]  
  xAuthUserToken.payload.roles[i].scope[_].organisationId == http_request.headers["x-channel-id"]
  xAuthUserId[2] == http_request.headers["x-authenticated-userid"]
}

not getDataExhaustRequest {
  http_request.headers["x-authenticated-userid"]
}

listDataExhaustRequest {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserToken.payload.roles[i].scope[_].organisationId == http_request.headers["x-channel-id"]
  xAuthUserId[2] == http_request.headers["x-authenticated-userid"]
}

not listDataExhaustRequest {
  http_request.headers["x-authenticated-userid"]
}

submitDataExhaustRequest {
  acls := ["submitDataExhaustRequest"]
  input.parsed_body.request.dataset in ["progress-exhaust", "response-exhaust", "userinfo-exhaust"]
  xAuthUserToken.payload.roles[_].role in ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

submitDataExhaustRequest {
  acls := ["submitDataExhaustRequest"]
  input.parsed_body.request.dataset == "druid-dataset"
  xAuthUserToken.payload.roles[_].role == ["PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

not submitDataExhaustRequest {
  http_request.headers["x-authenticated-userid"]
}