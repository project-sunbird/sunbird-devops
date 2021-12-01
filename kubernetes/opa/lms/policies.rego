package policies

import data.common as super

updateBatch {
  acls := ["updateBatch"]
  roles := ["COURSE_CREATOR", "COURSE_MENTOR"]
  super.aclCheck(acls)
  super.roleCheck(roles)
}

listCourseEnrollments {
  super.publicRoleCheck
  super.token_userid == split(http_request.path, "/")[5]
}

listCourseEnrollments {
  super.publicRoleCheck
  super.parentIdCheck
  super.for_token_userid == split(http_request.path, "/")[5]
}

readContentState {
  super.publicRoleCheck
  super.token_userid == input.parsed_body.request.userId
}

readContentState {
  super.publicRoleCheck
  super.parentIdCheck
  super.for_token_userid == input.parsed_body.request.userId
}

courseEnrolment {
  super.publicRoleCheck
  super.token_userid == input.parsed_body.request.userId
}

courseEnrolment {
  super.publicRoleCheck
  super.parentIdCheck
  super.for_token_userid == input.parsed_body.request.userId
}

courseUnEnrolment {
  super.publicRoleCheck
  super.token_userid == input.parsed_body.request.userId
}

courseUnEnrolment {
  super.publicRoleCheck
  super.parentIdCheck
  super.for_token_userid == input.parsed_body.request.userId
}

updateContentState {
  super.publicRoleCheck
  super.token_userid == input.parsed_body.request.userId
}

updateContentState {
  super.publicRoleCheck
  super.parentIdCheck
  super.for_token_userid == input.parsed_body.request.userId
}

updateContentState {
  super.publicRoleCheck
  super.token_userid == input.parsed_body.request.assessments.userId
}

updateContentState {
  super.publicRoleCheck
  super.parentIdCheck
  super.for_token_userid == input.parsed_body.request.assessments.userId
}

updateContentState {
  super.publicRoleCheck
  super.token_userid == input.parsed_body.request.userId
  super.token_userid == input.parsed_body.request.assessments.userId
}

updateContentState {
  super.publicRoleCheck
  super.parentIdCheck
  super.for_token_userid == input.parsed_body.request.userId
  super.for_token_userid == input.parsed_body.request.assessments.userId
}