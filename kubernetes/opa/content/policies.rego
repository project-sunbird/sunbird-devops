package policies

import data.general as super
import future.keywords.in
import input.attributes.request.http as http_request

collectionImport {
  acls := ["collectionImport"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  super.role_check(roles)
}

collectionExport {
  acls := ["collectionExport"]
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

submitContentForReview {
  acls := ["submitContentForReview"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  super.role_check(roles)
}