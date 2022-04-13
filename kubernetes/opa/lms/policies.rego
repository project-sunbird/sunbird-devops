package policies

import data.common as super
import input.attributes.request.http as http_request

urls_to_action_mapping := {
  "/v1/course/batch/update": "updateBatch",
  "/v1/user/courses/list": "listCourseEnrollments",
  "/v1/course/enroll": "courseEnrollment",
  "/v1/course/unenroll": "courseUnEnrollment",
  "/v1/content/state/read": "readContentState",
  "/v1/content/state/update": "updateContentState"
}

updateBatch {
  acls := ["updateBatch"]
  roles := ["CONTENT_CREATOR", "COURSE_CREATOR", "COURSE_MENTOR"]
  super.acls_check(acls)
  super.role_check(roles)
}

listCourseEnrollments {
  super.public_role_check
  user_id := split(http_request.path, "/")[5]
  super.userid == split(user_id, "?")[0]
}

courseEnrollment {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
}

courseUnEnrollment {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
}

readContentState {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
}

readContentState {
  super.public_role_check
  not input.parsed_body.request.userId
}

updateContentState {
  super.public_role_check
  super.userid == input.parsed_body.request.userId
}

updateContentState {
  super.public_role_check
  not input.parsed_body.request.userId
}

# Todo
# Check input.parsed_body.request.assessments[_].userId with userid to ensure all userids are same for updateContentState