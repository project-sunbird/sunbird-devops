package policies

import data.common as super
import future.keywords.in
import input.attributes.request.http as http_request

urls_to_action_mapping := {   
   "/v1/content/copy": "copyContent",
   "/v1/content/create": "createContent",
   "/v1/lock/create": "createLock",
   "/v1/content/publish": "publishContent",
   "/v1/content/collaborator/update": "updateCollaborators"
}

copyContent {
  acls := ["copyContent"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  super.role_check(roles)
}

createContent {
  acls := ["createContent"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  super.role_check(roles)
  token_organisationids := super.org_check(roles)
  input.parsed_body.request.content.createdFor in token_organisationids
  input.parsed_body.request.content.createdBy == super.userid
}

createLock {
  acls := ["createLock"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "BOOK_REVIEWER", "CONTENT_REVIEWER"]
  super.acls_check(acls)
  super.role_check(roles)
}

publishContent {
  acls := ["publishContent"]
  roles := ["BOOK_REVIEWER", "CONTENT_REVIEWER", "FLAG_REVIEWER"]
  super.acls_check(acls)
  super.role_check(roles)
}

updateCollaborators {
  acls := ["updateCollaborators"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  super.role_check(roles)
}