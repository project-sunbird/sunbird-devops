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

updateBatch {
  acls := ["courseUpdate"]
  ROLES[token.payload.roles[_].role][_] == acls[_]
}

listCourseEnrollments {
  acls := ["courseAccess"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  split(http_request.path, "/")[6] == xAuthUserId[2]
}

listCourseEnrollments {
  acls := ["courseAccess"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  split(http_request.path, "/")[6] == xAuthForToken.payload.sub
}

readContentState {
  acls := ["userAdmin"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

readContentState {
  acls := ["userAdmin"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

courseEnrolment {
  acls := ["contentAccess"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

courseEnrolment {
  acls := ["contentAccess"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

courseUnEnrolment {
  acls := ["contentCreate"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

courseUnEnrolment {
  acls := ["contentCreate"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

updateContentState {
  acls := ["contentAdmin"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
}

updateContentState {
  acls := ["contentAdmin"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
}

updateContentState {
  acls := ["contentAdmin"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.assessments.userId == xAuthUserId[2]
}

updateContentState {
  acls := ["contentAdmin"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.assessments.userId == xAuthForToken.payload.sub
}

updateContentState {
  acls := ["contentAdmin"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  input.parsed_body.request.userId == xAuthUserId[2]
  input.parsed_body.request.assessments.userId == xAuthUserId[2]
}

updateContentState {
  acls := ["contentAdmin"]
  xAuthUserId := split(xAuthUserToken.payload.sub, ":")
  federationId == xAuthUserId[1]
  xAuthUserId[2] == xAuthForToken.payload.parentId
  input.parsed_body.request.userId == xAuthForToken.payload.sub
  input.parsed_body.request.assessments.userId == xAuthForToken.payload.sub
}