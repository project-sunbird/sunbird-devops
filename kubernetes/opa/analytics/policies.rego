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

getDataExhaustRequest {
  acls := ["dataAccess"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]  
  xAuthUserToken.payload.roles[i].scope[_].organisationId == http_request.headers["X-Channel-ID"]
  xAuthUserId[2] == http_request.headers["X-Authenticated-Userid"]
}

listDataExhaustRequest {
  acls := ["dataAccess"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserToken.payload.roles[i].scope[_].organisationId == http_request.headers["X-Channel-ID"]
  xAuthUserId[2] == http_request.headers["X-Authenticated-Userid"]
}

submitDataExhaustRequest {
  acls := ["dataCreate"]
  input.parsed_body.request.dataset in ["progress-exhaust", "response-exhaust", "userinfo-exhaust"]
  xAuthUserToken.payload.roles[_].role in ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

submitDataExhaustRequest {
  acls := ["dataCreate"]
  input.parsed_body.request.dataset == "druid-dataset"
  xAuthUserToken.payload.roles[_].role == ["PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}