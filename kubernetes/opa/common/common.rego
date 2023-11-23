package common

import input.attributes.request.http as http_request
import future.keywords.in

ROLES := {
   "BOOK_REVIEWER": ["createLock", "publishContent", "listLock", "retireLock", "refreshLock", "rejectContent", "rejectContentV2"],
   
   "CONTENT_REVIEWER": ["createLock", "publishContent", "listLock", "retireLock", "refreshLock", "rejectContent", "rejectContentV2"],
   
   "FLAG_REVIEWER": ["publishContent", "rejectContent", "rejectContentV2"],
   
   "BOOK_CREATOR": ["copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReviewV1", "submitContentForReviewV3", "createAsset", "uploadAsset", "updateAsset", "uploadUrlAsset", "copyAsset", "listLock", "retireLock", "refreshLock", "updateContent", "uploadContent"],
   
   "CONTENT_CREATOR": ["updateBatch", "copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReviewV1", "submitContentForReviewV3", "submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest", "createAsset", "uploadAsset", "updateAsset", "uploadUrlAsset", "copyAsset", "listLock", "retireLock", "refreshLock", "updateContent", "uploadContent", "courseBatchAddCertificateTemplate", "courseBatchRemoveCertificateTemplate", "createBatch"],
   
   "COURSE_CREATOR": ["updateBatch", "copyContent", "createContent", "createLock", "updateCollaborators", "collectionImport", "collectionExport", "submitContentForReviewV1", "submitContentForReviewV3", "createAsset", "uploadAsset", "updateAsset", "uploadUrlAsset", "copyAsset", "listLock", "retireLock", "refreshLock",  "updateContent", "uploadContent", "courseBatchAddCertificateTemplate", "courseBatchRemoveCertificateTemplate", "createBatch"],
   
   "COURSE_MENTOR": ["updateBatch", "submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest", "courseBatchAddCertificateTemplate", "courseBatchRemoveCertificateTemplate", "createBatch"],
   
   "PROGRAM_MANAGER": ["submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest"],
   
   "PROGRAM_DESIGNER": ["submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest"],
   
   "ORG_ADMIN": ["acceptTnc", "assignRole", "submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest", "getUserProfileV5", "updateUserV2", "readUserConsent", "createTenantPreferences", "updateTenantPreferences", "createReport", "deleteReport", "updateReport", "publishReport", "retireReport", "getReportSummary", "listReportSummary", "createReportSummary"],
   
   "REPORT_VIEWER": ["acceptTnc", "getReportSummary", "listReportSummary"],
   
   "REPORT_ADMIN": ["submitDataExhaustRequest", "getDataExhaustRequest", "listDataExhaustRequest", "acceptTnc", "createReport", "deleteReport", "updateReport", "publishReport", "retireReport", "getReportSummary", "listReportSummary", "createReportSummary"],

   "PUBLIC": ["PUBLIC"]
}

x_authenticated_user_token := http_request.headers["x-authenticated-user-token"]
x_authenticated_for := http_request.headers["x-authenticated-for"]
private_ingressgateway_ip := "{{ private_ingressgateway_ip }}"

# The below block (jwt_public_keys) will be expanded by ansible during deployment as below
# jwt_public_keys := {
#     "accessv1_key1": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw1nTpgDi10Sls2Fnk6Iy\n+TPah8HNvQbE0Dm/hpbqU0IVvq28iJf+9b6y4STkvmW5rLzUOZW5BenrWFdQPGMT\n+fnNAnVG7ByQMizJfpdHOuXi7iZsOZ2Ms+9UTMfvmE+GIdp/nDfZ55b8RQAJYr2w\nhd0td7idNnLX8Zo9FZ4eaJ9f0M391v+pkXo9pdistsuuvIapT+COeFex68G0iTSO\n7vYHy3+M5Pkefmh5ftRgcWqoXrTrBZ0ajdW8gcjbOmBXiFHSYD/VLEwTCpeOJIUR\nQ3/dFCoS3KpBfx4p0Wc9117PRT433bGAmgcG4yFtgkIPf8aosSA3Es8DD+U9dlbm\nzQIDAQAB\n-----END PUBLIC KEY-----",
#     "hhzZXoTbJBUQ": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwTS+srpbA/n7I5fDjxcf\nH1QUSiFMP7B4yyLxir3VigKtai+YW7ZqMF853O3OiE/QTKuT0ZsR7aDtCsoZaGqq\n2NSyfbc3m339dBQ+0YgM5UdqvUHubNkgQwkRwb1lGlMWSHMYk0iIKJEIw1MCdCH0\nOBwjzlDxHb78lCKd/GvBvRLMXOJbAP72xJ/gjaNFHQ/GzskhrapDuMXaH+S7vtox\nBDG74fQwXCG+nDJ9ryV2bbWxWMINLU82x3+L6YYnWK80loucm2fzG5l1W/Wz9DIa\nGiWwP0JHlZf9GM/raydB4kDEq3jB22LfdLCdQanMkxbw7bkmvjBT2NFwqgFv3q3m\nVQIDAQAB\n-----END PUBLIC KEY-----"
# }

jwt_public_keys := {
{{ public_access_keys | indent( width=2, indentfirst=True) }}
{% if opa_test_case_run is undefined or not opa_test_case_run %}
  "{{ adminutil_refresh_token_public_key_kid }}": "{{ keycloak_public_key.stdout }}"
{% endif %}
}

user_token := {"header": header, "payload": payload} {
  encoded := x_authenticated_user_token
  [header, payload, _] := io.jwt.decode(encoded)
}

for_token := {"payload": payload} {
  encoded := x_authenticated_for
  [_, payload, _] := io.jwt.decode(encoded)
}

iss := "{{ keycloak_auth_server_url }}/realms/{{ keycloak_realm }}"
token_kid := user_token.header.kid
token_iss := user_token.payload.iss
token_exp := user_token.payload.exp
current_time := time.now_ns()

token_sub := split(user_token.payload.sub, ":")
# Check for both cases - With and without federation_id in sub field as below
# sub := f:federation_id:user_id OR sub := user_id
token_userid = token_sub[2] {
    count(token_sub) == 3
} else = token_sub[0] {
    count(token_sub) == 1
}
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

for_token_exists {
  x_authenticated_for
  count(x_authenticated_for) > 0
}

userid = token_userid {
    not x_authenticated_for
} else = token_userid {
    count(x_authenticated_for) == 0 # This is a temporary fix as the mobile app is sending empty headers as x-authenticated-for: ""
} else = for_token_userid {
    for_token_exists
}

validate_token {
  io.jwt.verify_rs256(x_authenticated_user_token, jwt_public_keys[token_kid])
  token_exp * 1000000000 > current_time
  token_iss == iss
}

is_an_internal_request {
  http_request.host == private_ingressgateway_ip
}

acls_check(acls) = indicies {
  validate_token
  indicies := [idx | some i; ROLES[token_roles[i].role][_] == acls[_]; idx := i]
  count(indicies) > 0
}

role_check(roles) = indicies {
  indicies := [idx | some i; token_roles[i].role in roles; idx := i]
  count(indicies) > 0
}

org_check(roles) = token_organisationids {
  indicies :=  role_check(roles)
  count(indicies) > 0
  token_organisationids := [ids | ids := token_roles[indicies[_]].scope[_].organisationId]
  count(token_organisationids) > 0
}

parent_id_check {
    x_authenticated_for
    count(x_authenticated_for) > 0
    token_userid == for_token_parentid
}

parent_id_check {
    count(x_authenticated_for) == 0
}

parent_id_check {
    not x_authenticated_for
}

public_role_check {
  acls := ["PUBLIC"]
  roles := ["PUBLIC"]
  acls_check(acls)
  role_check(roles)
  userid
  parent_id_check
}

# We are not checking Audience (aud) claim as of now
# We don't use this claim field for anything yet in sunbird
# A probable use case would be to whitelist certain audience from checks in future
# The aud field needs to still be attached from Keycloak to be openid compliant
# Invoke `aud_check` from validate_token block when we want to use this

# Jinja comment block {# #}
# {# allowed_aud := { {{ keycloak_allowed_aud }} } #}
# token_aud := user_token.payload.aud

# aud_check {
#   type_name(token_aud) == "array"
#   matching_auds := [aud | some i; token_aud[i] in allowed_aud; aud := token_aud[i]]
#   count(token_aud) == count(matching_auds)
# }

# aud_check {
#   type_name(token_aud) == "string"
#   token_aud in allowed_aud
# }

# Algorithm checks are not being done as of now since we use only RS256 tokens
# A probable use case would be to check alg claim field when we use mutiple algorithms to issue tokens
# Add `token_alg == "RS256"` in validate_token block when we want to use this

# token_alg := user_token.header.alg
