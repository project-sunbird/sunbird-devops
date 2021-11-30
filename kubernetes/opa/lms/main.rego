package main

import input.attributes.request.http as http_request

default allow = false

urls[keys] { urls_to_action_mapping[keys]}   

urls_to_action_mapping := {
   "/course/v1/batch/update": "updateBatch",
   "/course/v1/user/enrollment/list": "listCourseEnrollments",
   "/course/v1/content/state/read": "readContentState",
   "/course/v1/enroll": "courseEnrolment",
   "/course/v1/unenrol": "courseUnEnrolment",
   "/course/v1/content/state/update": "updateContentState"
}

identified_url := regex.find_n(urls[_], http_request.path, 1)[0]
identified_action := urls_to_action_mapping[identified_url]

allow {
   data.policies[identified_action]
}
