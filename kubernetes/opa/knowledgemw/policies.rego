package policies

import data.general as super
import future.keywords.in
import input.attributes.request.http as http_request

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
  http_request.headers["x-channel-id"] in token_organisationids
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