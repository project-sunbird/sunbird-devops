package policies

import data.common as super
import future.keywords.in
import input.attributes.request.http as http_request

urls_to_action_mapping := {   
  "/request/read": "getDataExhaustRequest",
  "/request/list": "listDataExhaustRequest",
  "/request/submit": "submitDataExhaustRequest"
}

getDataExhaustRequest {
  acls := ["getDataExhaustRequest"]
  roles := ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR", "PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  super.acls_check(acls)
  super.role_check(roles)
  http_request.headers["x-channel-id"]
  http_request.headers["x-authenticated-userid"] == super.userid
}

getDataExhaustRequest {
  acls := ["getDataExhaustRequest"]
  roles := ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR", "PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  super.acls_check(acls)
  super.role_check(roles)  
  http_request.headers["x-channel-id"]
  not http_request.headers["x-authenticated-userid"]
}

getDataExhaustRequest {
  not http_request.headers["x-authenticated-user-token"]
}

listDataExhaustRequest {
  acls := ["listDataExhaustRequest"]
  roles := ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR", "PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  super.acls_check(acls)
  super.role_check(roles)  
  http_request.headers["x-channel-id"]
  http_request.headers["x-authenticated-userid"] == super.userid
}

listDataExhaustRequest {
  acls := ["listDataExhaustRequest"]
  roles := ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR", "PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  super.acls_check(acls)
  super.role_check(roles)  
  http_request.headers["x-channel-id"]
  not http_request.headers["x-authenticated-userid"]
}

listDataExhaustRequest {
  not http_request.headers["x-authenticated-user-token"]
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

submitDataExhaustRequest {
  not http_request.headers["x-authenticated-user-token"]
}