package policies

import data.general as super
import future.keywords.in
import input.attributes.request.http as http_request

getDataExhaustRequest {
  super.public_role_check
  http_request.headers["x-channel-id"]
  http_request.headers["x-authenticated-userid"] == super.userid
}

getDataExhaustRequest {
  super.public_role_check
  http_request.headers["x-channel-id"]
  not http_request.headers["x-authenticated-userid"]
}

listDataExhaustRequest {
  super.public_role_check
  http_request.headers["x-channel-id"]
  http_request.headers["x-authenticated-userid"] == super.userid
}

listDataExhaustRequest {
  super.public_role_check
  http_request.headers["x-channel-id"]
  not http_request.headers["x-authenticated-userid"]
}

submitDataExhaustRequest {
  acls := ["submitDataExhaustRequest"]
  roles := ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR"]
  super.acls_check(acls)
  super.role_check(roles)
  input.parsed_body.request.dataset in ["progress-exhaust", "response-exhaust", "userinfo-exhaust"]
  http_request.headers["x-channel-id"]
  http_request.headers["x-authenticated-userid"] == super.userid
}

submitDataExhaustRequest {
  acls := ["submitDataExhaustRequest"]
  roles := ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR"]
  super.acls_check(acls)
  super.role_check(roles)
  input.parsed_body.request.dataset in ["progress-exhaust", "response-exhaust", "userinfo-exhaust"]
  http_request.headers["x-channel-id"]
  not http_request.headers["x-authenticated-userid"]
}

submitDataExhaustRequest {
  acls := ["submitDataExhaustRequest"]
  roles :=["PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  super.acls_check(acls)
  super.role_check(roles)
  input.parsed_body.request.dataset in ["druid-dataset"]
  http_request.headers["x-channel-id"]
  http_request.headers["x-authenticated-userid"] == super.userid
}

submitDataExhaustRequest {
  acls := ["submitDataExhaustRequest"]
  roles :=["PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  super.acls_check(acls)
  super.role_check(roles)
  input.parsed_body.request.dataset in ["druid-dataset"]
  http_request.headers["x-channel-id"]
  not http_request.headers["x-authenticated-userid"]
}