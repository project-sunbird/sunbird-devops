package main

import input.attributes.request.http as http_request

default allow = false

urls[keys] { urls_to_action_mapping[keys]}

urls_to_action_mapping := {
   "/v1/course/batch/update": "updateBatch",
   "/v1/user/courses/list": "listCourseEnrollments",
   "/v1/content/state/read": "readContentState",
   "/v1/course/enroll": "courseEnrolment",
   "/v1/course/unenroll": "courseUnEnrolment",
   "/v1/content/state/update": "updateContentState"
}

identified_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_action := urls_to_action_mapping[identified_url]

allow {
   data.policies[identified_action]
}
