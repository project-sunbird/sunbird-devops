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
  
  # Due to portal legacy code, we need to add REVIEWER roles also for this API, this has to be fixed
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR", "BOOK_REVIEWER", "CONTENT_REVIEWER"]
  super.acls_check(acls)
  
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  
  # The below payload is being invoked when creating contents
  input.parsed_body.request.content.createdFor[_] in token_organisationids
  input.parsed_body.request.content.createdBy == super.userid
}

createContent {
  acls := ["createContent"]
  
  # Due to portal legacy code, we need to add REVIEWER roles also for this API, this has to be fixed
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR", "BOOK_REVIEWER", "CONTENT_REVIEWER"]
  super.acls_check(acls)
  
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)

  # The below payload is being invoked when creating certificate templates
  input.parsed_body.request.content.channel in token_organisationids
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