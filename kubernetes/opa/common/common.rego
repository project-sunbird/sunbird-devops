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

# This block will be expanded by ansible during deployment as below
# jwt_public_keys := {
#     "key0": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw1nTpgDi10Sls2Fnk6Iy\n+TPah8HNvQbE0Dm/hpbqU0IVvq28iJf+9b6y4STkvmW5rLzUOZW5BenrWFdQPGMT\n+fnNAnVG7ByQMizJfpdHOuXi7iZsOZ2Ms+9UTMfvmE+GIdp/nDfZ55b8RQAJYr2w\nhd0td7idNnLX8Zo9FZ4eaJ9f0M391v+pkXo9pdistsuuvIapT+COeFex68G0iTSO\n7vYHy3+M5Pkefmh5ftRgcWqoXrTrBZ0ajdW8gcjbOmBXiFHSYD/VLEwTCpeOJIUR\nQ3/dFCoS3KpBfx4p0Wc9117PRT433bGAmgcG4yFtgkIPf8aosSA3Es8DD+U9dlbm\nzQIDAQAB\n-----END PUBLIC KEY-----"
# }

jwt_public_keys := {
  {{ public_access_keys }}
  "{{ adminutil_refresh_token_public_key_kid }}": "{{ keycloak_public_key.stdout }}"
}

user_token := {"header": header, "payload": payload} {
  encoded := http_request.headers["x-authenticated-user-token"]
  [header, payload, _] := io.jwt.decode(encoded)
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

validate_token {
  kid = user_token.header.kid
  io.jwt.verify_rs256(http_request.headers["x-authenticated-user-token"], jwt_public_keys[kid])
}

acls_check(acls) = indicies {
  validate_token
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