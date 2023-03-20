package policies

import data.common as super
import input.attributes.request.http as http_request

urls_to_action_mapping := {
  "/v1/course/batch/update": "updateBatch",
  "/v1/user/courses/list": "listCourseEnrollments",
  "/v1/course/enroll": "courseEnrollment",
  "/v1/course/unenroll": "courseUnEnrollment",
  "/v1/content/state/read": "readContentState",
  "/v1/content/state/update": "updateContentState",
  "/v1/course/batch/cert/template/add": "courseBatchAddCertificateTemplate",
  "/v1/course/batch/cert/template/remove": "courseBatchRemoveCertificateTemplate",
  "/v1/course/batch/create": "createBatch",
  "/v1/course/batch/read": "getBatch"
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
  split(user_id, "?")[0] == super.userid
}

courseEnrollment {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
}

courseUnEnrollment {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
}

readContentState {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
}

readContentState {
  super.public_role_check
  not input.parsed_body.request.userId
}

# With userid and without assessments event in payload
updateContentState {
  super.public_role_check
  not input.parsed_body.request.assessments
  input.parsed_body.request.userId == super.userid
}

# Without userid and without assessments event in payload
updateContentState {
  super.public_role_check
  not input.parsed_body.request.userId
  not input.parsed_body.request.assessments
}

# With userid and with assessments event in payload
updateContentState {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
  assessment_userids := {ids | ids := input.parsed_body.request.assessments[_].userId}
  count(assessment_userids) == 1
  assessment_userids[super.userid] == super.userid
}

# Without userid and with assessments event in payload
updateContentState {
  super.public_role_check
  not input.parsed_body.request.userId
  assessment_userids := {ids | ids := input.parsed_body.request.assessments[_].userId}
  count(assessment_userids) == 1
  assessment_userids[super.userid] == super.userid
}

courseBatchAddCertificateTemplate {
  acls := ["courseBatchAddCertificateTemplate"]
  roles := ["CONTENT_CREATOR", "COURSE_CREATOR", "COURSE_MENTOR"]
  super.acls_check(acls)
  super.role_check(roles)  
}

courseBatchRemoveCertificateTemplate {
  acls := ["courseBatchRemoveCertificateTemplate"]
  roles := ["CONTENT_CREATOR", "COURSE_CREATOR", "COURSE_MENTOR"]
  super.acls_check(acls)
  super.role_check(roles)  
}

createBatch {
  acls := ["createBatch"]
  roles := ["CONTENT_CREATOR", "COURSE_CREATOR", "COURSE_MENTOR"]
  super.acls_check(acls)
  super.role_check(roles)  
}

getBatch {
  super.public_role_check
}