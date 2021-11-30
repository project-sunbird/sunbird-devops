# package common

# import input.attributes.request.http as http_request

# ROLES := {
#    "BOOK_CREATOR": ["contentCreate", "contentAccess", "contentAdmin", "contentUpdate"],
#    "BOOK_REVIEWER": ["contentCreate", "contentAdmin"],
#    "CONTENT_CREATOR": ["contentCreate", "contentAccess", "contentAdmin", "contentUpdate"],
#    "COURSE_CREATOR": ["contentCreate", "contentAccess", "contentAdmin", "contentUpdate"],
#    "CONTENT_REVIEWER": ["contentCreate", "contentAdmin"],
#    "FLAG_REVIEWER": ["contentAdmin"],
#    "ORG_ADMIN": ["userAdmin"],
#    "PUBLIC": ["PUBLIC"]
# }

# # roleCheck(acls) = indexes {
# #   indexes = [i | some i; ROLES[xAuthUserToken.payload.roles[i].role][_] == acls[_]]
# # }

# # orgCheckInRequestHeader(acls, header) {
# #   roleIndexes := roleCheck(acls)
# #   token.payload.roles[roleIndexes[_]].scope[_].organisationId == http_request.headers[header]
# # }

# # orgCheckInRequestPayload(acls, payload) {
# #   roleIndexes := roleCheck(acls)
# #   token.payload.roles[roleIndexes[_]].scope[_].organisationId == input.parsed_body[request.organisationId]
# # }

# federationIdCheck {
#   federationId == sub[1]
# }

# #federationId := "{{ core_vault_sunbird_keycloak_user_federation_provider_id }}"
# federationId := "5a8a3f2b-3409-42e0-9001-f913bc0fde31"

# sub := split(token.payload.sub, ":")

# # token := {"payload": payload} {
# #   [_, encoded] := split(http_request.headers.authorization, " ")
# #   [_, payload, _] := io.jwt.decode(encoded)
# # }