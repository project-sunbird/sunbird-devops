package common

import input.attributes.request.http as http_request
import future.keywords.in

federation_id := "{{ core_vault_sunbird_keycloak_user_federation_provider_id }}"

ROLES := {
   "BOOK_REVIEWER": ["createLock", "publishContent"],
   "CONTENT_REVIEWER": ["createLock", "publishContent"],
   "FLAG_REVIEWER": ["publishContent"],
   "BOOK_CREATOR": ["copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview"],
   "CONTENT_CREATOR": ["copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview", "submitDataExhaustRequest"],
   "COURSE_CREATOR": ["updateBatch", "copyContent", "createContent", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview"],
   "COURSE_MENTOR": ["updateBatch", "submitDataExhaustRequest"],
   "PROGRAM_MANAGER": ["submitDataExhaustRequest"],
   "PROGRAM_DESIGNER": ["submitDataExhaustRequest"],
   "ORG_ADMIN": ["acceptTnc", "assignRole", "submitDataExhaustRequest"],
   "REPORT_VIEWER": ["acceptTnc"],
   "REPORT_ADMIN": ["submitDataExhaustRequest"],
   "PUBLIC": ["PUBLIC"]
}

user_token := {"payload": payload} {
  encoded := http_request.headers["x-authenticated-user-token"]
  [_, payload, _] := io.jwt.decode(encoded)
}

for_token := {"payload": payload} {
  encoded := http_request.headers["x-authenticated-for"]
  [_, payload, _] := io.jwt.decode(encoded)
}

token_sub := split(user_token.payload.sub, ":")
token_federation_id := token_sub[1]
token_userid := token_sub[2]
for_token_userid := for_token.payload.sub
for_token_parentid := for_token.payload.parentId
token_roles := user_token.payload.roles

userid = token_userid {
    not http_request.headers["x-authenticated-for"]
} else = for_token_userid {
    http_request.headers["x-authenticated-for"]
}

acls_check(acls) {
  ROLES[token_roles[_].role][_] == acls[_]
}

role_check(roles) {
  token_roles[_].role in roles
}

federation_id_check {
  federation_id := token_federation_id
}

parent_id_check {
    http_request.headers["x-authenticated-for"]
    token_userid == for_token_parentid
}

parent_id_check {
    not http_request.headers["x-authenticated-for"]
}

public_role_check {
  acls := ["PUBLIC"]
  roles := ["PUBLIC"]
  acls_check(acls)
  role_check(roles)
  federation_id_check
  parent_id_check
}