package policies

import data.common as super
import future.keywords.in

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
  # acls := ["createContent"]
  #
  #  # Due to portal legacy code, we need to add REVIEWER roles also for this API
  # roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR", "BOOK_REVIEWER", "CONTENT_REVIEWER"]
  # super.acls_check(acls)
  #
  #  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  # token_organisationids := super.org_check(roles)
  #
  #  # The below payload is being invoked when creating contents
  # input.parsed_body.request.content.createdFor[_] in token_organisationids
  # input.parsed_body.request.content.createdBy == super.userid

  # This rule has been disabled since request from VDN flink job is directly invoking content service 
  # via private ingress and is not passing any tokens / headers.
  # Hence this is blocking the creation workflow in VDN.
  # This should be moved to a system token if invoked via private ingess.
  true
}

submitContentForReview {
  acls := ["submitContentForReview"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  super.role_check(roles)
}