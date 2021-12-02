package policies

import data.general as super
import input.attributes.request.http as http_request

updateBatch {
  acls := ["updateBatch"]
  roles := ["COURSE_CREATOR", "COURSE_MENTOR"]
  super.acls_check(acls)
  super.role_check(roles)
}

listCourseEnrollments {
  super.public_role_check
  super.userid == split(http_request.path, "/")[5]
}

readContentState {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
}

courseEnrolment {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
}

courseUnEnrolment {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
}

updateContentState {
  super.public_role_check
  not input.parsed_body.request.assessments.userId
  super.userid == input.parsed_body.request.userId
}

updateContentState {
  super.public_role_check
  not input.parsed_body.request.userId
  super.userid == input.parsed_body.request.assessments.userId
}

updateContentState {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
  super.userid == input.parsed_body.request.assessments.userId
}