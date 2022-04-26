package tests

# The tokens used in test cases expire on 1640236102
# So we set the current_time to a few minutes earlier than the expiry
# This will ensure the test cases succeed

current_time := 1640235102
iss := "https://sunbirded.org/auth/realms/sunbird"

test_get_data_exhaust_request {
    data.main.allow.allowed
    with data.common.current_time as current_time
    with data.common.iss as iss
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJhdWQiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsInN1YiI6ImY6NWJiNmM4N2MtN2M4OC00ZDJiLWFmN2UtNTM0YTJmZWY5NzhkOjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInJvbGVzIjpbeyJyb2xlIjoiQk9PS19DUkVBVE9SIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPTlRFTlRfQ1JFQVRPUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJDT05URU5UX1JFVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPVVJTRV9NRU5UT1IiLCJzY29wZSI6W3sib3JnYW5pc2F0aW9uSWQiOiIwMTM2OTg3ODc5NzUwMzY5MjgxMCJ9XX0seyJyb2xlIjoiUFJPR1JBTV9ERVNJR05FUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJSRVBPUlRfVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6Ik9SR19BRE1JTiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn0seyJvcmdhbmlzYXRpb25JZCI6IjAxNDcxOTIzNTY3ODEyMzQ1Njc4In1dfSx7InJvbGUiOiJQVUJMSUMiLCJzY29wZSI6W119XSwiaXNzIjoiaHR0cHM6Ly9zdW5iaXJkZWQub3JnL2F1dGgvcmVhbG1zL3N1bmJpcmQiLCJuYW1lIjoiZGVtbyIsInR5cCI6IkJlYXJlciIsImV4cCI6MTY0MDIzNjEwMiwiaWF0IjoxNjQwMTQ5NzA1fQ.B3-TSdYSOlawPHjFdiRjXwvRbYQ_eH_HTiLKlH7vGS0rCOJ6HQbYyWOhZ7vbZPb3virkuyfhykFcYCEHBCkHY-fwGAeU58Pmhi0dnNJkR59Fa9y_75W98JXZW68HROp62ntEAKCA1oot_U4tYi-8UNoR17Gszj9iYzFEBc6TZA4Lrom_9gqhBOYzL0ISFWSS6oG94EaaKDYHyWzCSjU2nYRB_fn-tODmnVJ12GRJAc1oM9y54o8neNYsl4T_xPyD34v-CinUJM8jzDjFqK5_O3HnAbcmXvkZjFRgfk4mF1V4s5hlsTJGyhi2JOPh90C5N-HbAY8QsPBnzgYFQU_sww",
              "x-channel-id": "01369878797503692810",
              "x-authenticated-userid": "28b0d08f-c2ea-40d1-bcd0-8ae00fca66be"
            },
            "path": "/request/read"
          }
        }
      }
    }
}

test_get_data_exhaust_request_without_user_token_without_userid {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-channel-id": "01369878797503692810"
            },
            "path": "/request/read"
          }
        }
      }
    }
}


test_list_data_exhaust_request {
    data.main.allow.allowed
    with data.common.current_time as current_time
    with data.common.iss as iss
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJhdWQiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsInN1YiI6ImY6NWJiNmM4N2MtN2M4OC00ZDJiLWFmN2UtNTM0YTJmZWY5NzhkOjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInJvbGVzIjpbeyJyb2xlIjoiQk9PS19DUkVBVE9SIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPTlRFTlRfQ1JFQVRPUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJDT05URU5UX1JFVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPVVJTRV9NRU5UT1IiLCJzY29wZSI6W3sib3JnYW5pc2F0aW9uSWQiOiIwMTM2OTg3ODc5NzUwMzY5MjgxMCJ9XX0seyJyb2xlIjoiUFJPR1JBTV9ERVNJR05FUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJSRVBPUlRfVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6Ik9SR19BRE1JTiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn0seyJvcmdhbmlzYXRpb25JZCI6IjAxNDcxOTIzNTY3ODEyMzQ1Njc4In1dfSx7InJvbGUiOiJQVUJMSUMiLCJzY29wZSI6W119XSwiaXNzIjoiaHR0cHM6Ly9zdW5iaXJkZWQub3JnL2F1dGgvcmVhbG1zL3N1bmJpcmQiLCJuYW1lIjoiZGVtbyIsInR5cCI6IkJlYXJlciIsImV4cCI6MTY0MDIzNjEwMiwiaWF0IjoxNjQwMTQ5NzA1fQ.B3-TSdYSOlawPHjFdiRjXwvRbYQ_eH_HTiLKlH7vGS0rCOJ6HQbYyWOhZ7vbZPb3virkuyfhykFcYCEHBCkHY-fwGAeU58Pmhi0dnNJkR59Fa9y_75W98JXZW68HROp62ntEAKCA1oot_U4tYi-8UNoR17Gszj9iYzFEBc6TZA4Lrom_9gqhBOYzL0ISFWSS6oG94EaaKDYHyWzCSjU2nYRB_fn-tODmnVJ12GRJAc1oM9y54o8neNYsl4T_xPyD34v-CinUJM8jzDjFqK5_O3HnAbcmXvkZjFRgfk4mF1V4s5hlsTJGyhi2JOPh90C5N-HbAY8QsPBnzgYFQU_sww",
              "x-channel-id": "01369878797503692810",
              "x-authenticated-userid": "28b0d08f-c2ea-40d1-bcd0-8ae00fca66be"
            },
            "path": "/request/list"
          }
        }
      }
    }
}

test_list_data_exhaust_request_without_user_token_without_userid {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-channel-id": "01369878797503692810"
            },
            "path": "/request/list"
          }
        }
      }
    }
}

test_submit_data_exhaust_request_with_dataset_as_progress_exhaust {
    data.main.allow.allowed
    with data.common.current_time as current_time
    with data.common.iss as iss
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJhdWQiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsInN1YiI6ImY6NWJiNmM4N2MtN2M4OC00ZDJiLWFmN2UtNTM0YTJmZWY5NzhkOjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInJvbGVzIjpbeyJyb2xlIjoiQk9PS19DUkVBVE9SIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPTlRFTlRfQ1JFQVRPUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJDT05URU5UX1JFVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPVVJTRV9NRU5UT1IiLCJzY29wZSI6W3sib3JnYW5pc2F0aW9uSWQiOiIwMTM2OTg3ODc5NzUwMzY5MjgxMCJ9XX0seyJyb2xlIjoiUFJPR1JBTV9ERVNJR05FUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJSRVBPUlRfVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6Ik9SR19BRE1JTiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn0seyJvcmdhbmlzYXRpb25JZCI6IjAxNDcxOTIzNTY3ODEyMzQ1Njc4In1dfSx7InJvbGUiOiJQVUJMSUMiLCJzY29wZSI6W119XSwiaXNzIjoiaHR0cHM6Ly9zdW5iaXJkZWQub3JnL2F1dGgvcmVhbG1zL3N1bmJpcmQiLCJuYW1lIjoiZGVtbyIsInR5cCI6IkJlYXJlciIsImV4cCI6MTY0MDIzNjEwMiwiaWF0IjoxNjQwMTQ5NzA1fQ.B3-TSdYSOlawPHjFdiRjXwvRbYQ_eH_HTiLKlH7vGS0rCOJ6HQbYyWOhZ7vbZPb3virkuyfhykFcYCEHBCkHY-fwGAeU58Pmhi0dnNJkR59Fa9y_75W98JXZW68HROp62ntEAKCA1oot_U4tYi-8UNoR17Gszj9iYzFEBc6TZA4Lrom_9gqhBOYzL0ISFWSS6oG94EaaKDYHyWzCSjU2nYRB_fn-tODmnVJ12GRJAc1oM9y54o8neNYsl4T_xPyD34v-CinUJM8jzDjFqK5_O3HnAbcmXvkZjFRgfk4mF1V4s5hlsTJGyhi2JOPh90C5N-HbAY8QsPBnzgYFQU_sww",
              "x-channel-id": "01369878797503692810",
              "x-authenticated-userid": "28b0d08f-c2ea-40d1-bcd0-8ae00fca66be"
            },
            "path": "/request/submit"
          }
        }
      },
      "parsed_body": {
        "request": {
          "dataset": "progress-exhaust",
          "tag": "do_2132633999849390081587_0132634259344588800",
          "datasetConfig": {
            "batchId": "0132634259344588800"
          },
          "requestedBy": "fcae65a6-8a48-11ec-8c82-c7075e84952d"
        }
      }
    }
}

test_submit_data_exhaust_request_with_dataset_as_druid_dataset {
    data.main.allow.allowed
    with data.common.current_time as current_time
    with data.common.iss as iss
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJhdWQiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsInN1YiI6ImY6NWJiNmM4N2MtN2M4OC00ZDJiLWFmN2UtNTM0YTJmZWY5NzhkOjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInJvbGVzIjpbeyJyb2xlIjoiQk9PS19DUkVBVE9SIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPTlRFTlRfQ1JFQVRPUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJDT05URU5UX1JFVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPVVJTRV9NRU5UT1IiLCJzY29wZSI6W3sib3JnYW5pc2F0aW9uSWQiOiIwMTM2OTg3ODc5NzUwMzY5MjgxMCJ9XX0seyJyb2xlIjoiUFJPR1JBTV9ERVNJR05FUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJSRVBPUlRfVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6Ik9SR19BRE1JTiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn0seyJvcmdhbmlzYXRpb25JZCI6IjAxNDcxOTIzNTY3ODEyMzQ1Njc4In1dfSx7InJvbGUiOiJQVUJMSUMiLCJzY29wZSI6W119XSwiaXNzIjoiaHR0cHM6Ly9zdW5iaXJkZWQub3JnL2F1dGgvcmVhbG1zL3N1bmJpcmQiLCJuYW1lIjoiZGVtbyIsInR5cCI6IkJlYXJlciIsImV4cCI6MTY0MDIzNjEwMiwiaWF0IjoxNjQwMTQ5NzA1fQ.B3-TSdYSOlawPHjFdiRjXwvRbYQ_eH_HTiLKlH7vGS0rCOJ6HQbYyWOhZ7vbZPb3virkuyfhykFcYCEHBCkHY-fwGAeU58Pmhi0dnNJkR59Fa9y_75W98JXZW68HROp62ntEAKCA1oot_U4tYi-8UNoR17Gszj9iYzFEBc6TZA4Lrom_9gqhBOYzL0ISFWSS6oG94EaaKDYHyWzCSjU2nYRB_fn-tODmnVJ12GRJAc1oM9y54o8neNYsl4T_xPyD34v-CinUJM8jzDjFqK5_O3HnAbcmXvkZjFRgfk4mF1V4s5hlsTJGyhi2JOPh90C5N-HbAY8QsPBnzgYFQU_sww",
              "x-channel-id": "01369878797503692810",
              "x-authenticated-userid": "28b0d08f-c2ea-40d1-bcd0-8ae00fca66be"
            },
            "path": "/request/submit"
          }
        }
      },
      "parsed_body": {
        "request": {
          "dataset": "druid-dataset",
          "tag": "do_2132633999849390081587_0132634259344588800",
          "datasetConfig": {
            "batchId": "0132634259344588800"
          },
          "requestedBy": "fcae65a6-8a48-11ec-8c82-c7075e84952d"
        }
      }
    }
}

test_submit_data_exhaust_request_with_dataset_as_progress_exhaust_without_user_token_without_userid {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-channel-id": "01369878797503692810"
            },
            "path": "/request/submit"
          }
        }
      },
      "parsed_body": {
        "request": {
          "dataset": "progress-exhaust",
          "tag": "do_2132633999849390081587_0132634259344588800",
          "datasetConfig": {
            "batchId": "0132634259344588800"
          },
          "requestedBy": "fcae65a6-8a48-11ec-8c82-c7075e84952d"
        }
      }
    }
}