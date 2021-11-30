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

collectionImport {
  acls := ["collectionImport"]
  xAuthUserToken.payload.roles[_].role in ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

collectionExport {
  acls := ["collectionExport"]
  xAuthUserToken.payload.roles[_].role in ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

createContent {
  acls := ["createContent"]
  xAuthUserToken.payload.roles[_].role in ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  some i; ROLES[xAuthUserToken.payload.roles[i].role][_] == acls[_]
  xAuthUserToken.payload.roles[i].scope[_].organisationId == http_request.headers["x-channel-id"]
}

submitContentForReview {
  acls := ["submitContentForReview"]
  xAuthUserToken.payload.roles[_].role in ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}