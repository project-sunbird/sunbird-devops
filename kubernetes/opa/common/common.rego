package common

import input.attributes.request.http as http_request
import future.keywords.in

ROLES := {
   "BOOK_REVIEWER": ["createLock", "publishContent"],
   "CONTENT_REVIEWER": ["createLock", "publishContent"],
   "FLAG_REVIEWER": ["publishContent"],
   "BOOK_CREATOR": ["copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview"],
   "CONTENT_CREATOR": ["updateBatch", "copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview", "submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest"],
   "COURSE_CREATOR": ["updateBatch", "copyContent", "createContent", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReview"],
   "COURSE_MENTOR": ["updateBatch", "submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest"],
   "PROGRAM_MANAGER": ["submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest"],
   "PROGRAM_DESIGNER": ["submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest"],
   "ORG_ADMIN": ["acceptTnc", "assignRole", "submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest"],
   "REPORT_VIEWER": ["acceptTnc"],
   "REPORT_ADMIN": ["submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest", "acceptTnc"],
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
token_userid := token_sub[2]
for_token_userid := for_token.payload.sub
for_token_parentid := for_token.payload.parentId

# Desktop app is still using keycloak tokens which will not have roles
# This is a temporary fix where we will append the roles as PUBLIC in OPA

default_role := [{"role": "PUBLIC", "scope": []}]

token_roles = user_token.payload.roles {
    user_token.payload.roles
} else = default_role {
    not user_token.payload.roles
}

userid = token_userid {
    not http_request.headers["x-authenticated-for"]
} else = token_userid {
    count(http_request.headers["x-authenticated-for"]) == 0 # This is a temporary fix as the mobile app is sending empty headers as x-authenticated-for: ""
} else = for_token_userid {
    http_request.headers["x-authenticated-for"]
    count(http_request.headers["x-authenticated-for"]) > 0
}

acls_check(acls) = indicies {
  indicies := [idx | some i; ROLES[token_roles[i].role][_] == acls[_]; idx = i]
  count(indicies) > 0
}

role_check(roles) = indicies {
  indicies := [idx | some i; token_roles[i].role in roles; idx = i]
  count(indicies) > 0
}

org_check(roles) = token_organisationids {
  indicies :=  role_check(roles)
  count(indicies) > 0
  token_organisationids := [ids | ids = token_roles[indicies[_]].scope[_].organisationId]
  count(token_organisationids) > 0
}

parent_id_check {
    http_request.headers["x-authenticated-for"]
    count(http_request.headers["x-authenticated-for"]) > 0
    token_userid == for_token_parentid
}

parent_id_check {
    count(http_request.headers["x-authenticated-for"]) == 0
}

parent_id_check {
    not http_request.headers["x-authenticated-for"]
}

public_role_check {
  acls := ["PUBLIC"]
  roles := ["PUBLIC"]
  acls_check(acls)
  role_check(roles)
  userid
  parent_id_check
}