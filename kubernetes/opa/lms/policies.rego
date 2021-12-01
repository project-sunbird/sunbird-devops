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

updateBatch {
  acls := ["updateBatch"]
  xAuthUserToken.payload.roles[_].role in ["COURSE_CREATOR", "COURSE_MENTOR"]
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
}

listCourseEnrollments {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  split(http_request.path, "/")[5] == xAuthUserId[2]
}

listCourseEnrollments {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  split(http_request.path, "/")[5] == xAuthForToken.payload.sub
}

readContentState {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

readContentState {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

courseEnrolment {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

courseEnrolment {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

courseUnEnrolment {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

courseUnEnrolment {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

updateContentState {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

updateContentState {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

updateContentState {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.assessments.userId == xAuthUserId[2]
}

updateContentState {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.assessments.userId == xAuthForToken.payload.sub
}

updateContentState {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
  input.parsed_body.request.assessments.userId == xAuthUserId[2]
}

updateContentState {
  acls := ["PUBLIC"]
  xAuthUserToken.payload.roles[_].role == "PUBLIC"
  ROLES[xAuthUserToken.payload.roles[_].role][_] == acls[_]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
  input.parsed_body.request.assessments.userId == xAuthForToken.payload.sub
}