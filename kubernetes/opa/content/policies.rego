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

collectionImport {
  acls := ["contentCreate"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

collectionExport {
  acls := ["contentAccess"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

createContent(acls) {
  acls := ["contentCreate"]
  some i; ROLES[xAuthUserToken.payload.roles[i].role][_] == acls[_]
  xAuthUserToken.payload.roles[i].scope[_].organisationId == http_request.headers["X-Channel-Id"]
}

submitContentForReview {
  acls := ["contentAdmin"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}