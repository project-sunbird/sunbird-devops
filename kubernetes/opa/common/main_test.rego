package main_test

test_not_allowed {
    not data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "path": "/url/not/allowed"
          }
        }
      }
    }
}

test_allowed {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-consumer-username": "mobile"
            },
            "path": "/url/allowed"
          }
        }
      }
    }
}


test_check_if_consumer_is_skipped {
    data.main.allow.allowed
    with data.main.skipped_consumers as ["desktop"]
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-consumer-username": "desktop"
            },
            "path": "/url/not/allowed"
          }
        }
      }
    }
}

test_url_path_not_matched {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "path": "/url/not/matched"
          }
        }
      }
    }
}