package policies

import data.common as super
import future.keywords.in
import input.attributes.request.http as http_request

x_channel_id := http_request.headers["x-channel-id"]
x_authenticated_userid := http_request.headers["x-authenticated-userid"]
x_authenticated_user_token := http_request.headers["x-authenticated-user-token"]

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
  x_channel_id
  x_authenticated_userid == super.userid
}

getDataExhaustRequest {
  not x_authenticated_user_token
  not x_authenticated_userid
}

listDataExhaustRequest {
  acls := ["listDataExhaustRequest"]
  roles := ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR", "PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  super.acls_check(acls)
  super.role_check(roles)  
  x_channel_id
  x_authenticated_userid == super.userid
}

listDataExhaustRequest {
  not x_authenticated_user_token
  not x_authenticated_userid
}

submitDataExhaustRequest {
  acls := ["submitDataExhaustRequest"]
  roles := ["ORG_ADMIN", "REPORT_ADMIN", "CONTENT_CREATOR", "COURSE_MENTOR"]
  super.acls_check(acls)
  super.role_check(roles)
  input.parsed_body.request.dataset in ["progress-exhaust", "response-exhaust", "userinfo-exhaust"]
  x_channel_id
  x_authenticated_userid == super.userid
}

submitDataExhaustRequest {
  acls := ["submitDataExhaustRequest"]
  roles :=["PROGRAM_MANAGER", "PROGRAM_DESIGNER"]
  super.acls_check(acls)
  super.role_check(roles)
  input.parsed_body.request.dataset in ["druid-dataset"]
  x_channel_id
  x_authenticated_userid == super.userid
}

submitDataExhaustRequest {
  not x_authenticated_user_token
  not x_authenticated_userid
}