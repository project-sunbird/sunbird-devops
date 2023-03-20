package policies

import data.common as super
import input.attributes.request.http as http_request

urls_to_action_mapping := {   
  "/v1/notification/feed/read": "readNotificationFeed",
  "/v1/notification/feed/delete": "deleteNotificationFeed",
  "/v1/notification/feed/update": "updateNotificationFeed"
}

readNotificationFeed {
  super.public_role_check
  user_id := split(http_request.path, "/")[5]
  split(user_id, "?")[0] == super.userid
}

deleteNotificationFeed {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
}

updateNotificationFeed {
  super.public_role_check
  input.parsed_body.request.userId == super.userid
}