package policies

import data.common as super
import future.keywords.in
import input.attributes.request.http as http_request

x_channel_id := http_request.headers["x-channel-id"]

urls_to_action_mapping := {
# "/content/v3/create": "createContent",
  "/collection/v4/import": "collectionImport",
  "/collection/v4/export": "collectionExport",
  "/content/v3/review": "submitContentForReviewV3",
  "/asset/v4/create": "createAsset",
  "/asset/v4/update": "updateAsset",
  "/asset/v4/upload/url": "uploadUrlAsset",
  "/asset/v4/upload": "uploadAsset",
  "/asset/v4/copy": "copyAsset",
  "/content/v4/reject": "rejectContentV2"
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

submitContentForReviewV3 {
  acls := ["submitContentForReviewV3"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  super.role_check(roles)
}

createAsset {
  acls := ["createAsset"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  x_channel_id in token_organisationids
  input.parsed_body.request.asset.channel in token_organisationids
  input.parsed_body.request.asset.channel == x_channel_id
  input.parsed_body.request.asset.createdBy == super.userid
}

# Optional request.asset.createdBy in payload - https://project-sunbird.atlassian.net/browse/SB-29753
createAsset {
  acls := ["createAsset"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  x_channel_id in token_organisationids
  input.parsed_body.request.asset.channel in token_organisationids
  input.parsed_body.request.asset.channel == x_channel_id
  not input.parsed_body.request.asset.createdBy
}

updateAsset {
  acls := ["updateAsset"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  x_channel_id in token_organisationids  
}

uploadAsset {
  acls := ["uploadAsset"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  x_channel_id in token_organisationids
}

uploadUrlAsset {
  acls := ["uploadUrlAsset"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  x_channel_id in token_organisationids    
}

copyAsset {
  acls := ["copyAsset"]
  roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR"]
  super.acls_check(acls)
  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
  token_organisationids := super.org_check(roles)
  x_channel_id in token_organisationids    
}

rejectContentV2 {
  acls := ["rejectContentV2"]
  roles := ["BOOK_REVIEWER", "CONTENT_REVIEWER", "FLAG_REVIEWER"]
  super.acls_check(acls)
  super.role_check(roles)
}


# createContent {
#   # acls := ["createContent"]
#   #
#   #  # Due to portal legacy code, we need to add REVIEWER roles also for this API
#   # roles := ["BOOK_CREATOR", "CONTENT_CREATOR", "COURSE_CREATOR", "BOOK_REVIEWER", "CONTENT_REVIEWER"]
#   # super.acls_check(acls)
#   #
#   #  # Org check will do an implicit role check so there is no need to invoke super.role_check(roles)
#   # token_organisationids := super.org_check(roles)
#   #
#   #  # The below payload is being invoked when creating contents
#   # input.parsed_body.request.content.createdFor[_] in token_organisationids
#   # input.parsed_body.request.content.createdBy == super.userid

#   # This rule has been disabled since request from VDN flink job is directly invoking content service 
#   # via private ingress and is not passing any tokens / headers.
#   # Hence this is blocking the creation workflow in VDN.
#   # This should be moved to a system token if invoked via private ingess.
#   true
# }