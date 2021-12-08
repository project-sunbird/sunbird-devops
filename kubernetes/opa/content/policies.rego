package policies

import data.common as super
import future.keywords.in
import input.attributes.request.http as http_request

urls_to_action_mapping := {   
   "/collection/v4/import": "collectionImport",
   "/collection/v4/export": "collectionExport",
   "/content/v3/create": "createContent",
   "/content/v3/review": "submitContentForReview"
}

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
  input.parsed_body.request.content.createdFor in token_organisationids
  input.parsed_body.request.content.createdBy == super.userid
}

submitContentForReview {
  acls := ["submitContentForReview"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  super.role_check(roles)
}