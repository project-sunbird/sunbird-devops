package common_test

test_public_role_check {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJhdWQiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsInN1YiI6ImY6NWJiNmM4N2MtN2M4OC00ZDJiLWFmN2UtNTM0YTJmZWY5NzhkOjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInJvbGVzIjpbeyJyb2xlIjoiQk9PS19DUkVBVE9SIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPTlRFTlRfQ1JFQVRPUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJDT05URU5UX1JFVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPVVJTRV9NRU5UT1IiLCJzY29wZSI6W3sib3JnYW5pc2F0aW9uSWQiOiIwMTM2OTg3ODc5NzUwMzY5MjgxMCJ9XX0seyJyb2xlIjoiUFJPR1JBTV9ERVNJR05FUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJSRVBPUlRfVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6Ik9SR19BRE1JTiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn0seyJvcmdhbmlzYXRpb25JZCI6IjAxNDcxOTIzNTY3ODEyMzQ1Njc4In1dfSx7InJvbGUiOiJQVUJMSUMiLCJzY29wZSI6W119XSwiaXNzIjoiaHR0cHM6Ly9zdW5iaXJkZWQub3JnL2F1dGgvcmVhbG1zL3N1bmJpcmQiLCJuYW1lIjoiZGVtbyIsInR5cCI6IkJlYXJlciIsImV4cCI6MTY0MDIzNjEwMiwiaWF0IjoxNjQwMTQ5NzA1fQ.RpFX4awKLo5kGrJallN5ErsGUOz1G3wuR5ro5egaxRs3V47aXVoLIaxozj0KEOWpaLl1Nn5R7JdFJ7SDWXX9CBR72VFbyW4dx25_1yh49E6Bdjzke0tiZeBWGKT2GqaHfYJ4mXGn-V7nAsY4iQfPL8ftaoYtrEK7hyDf0uM0_pM_tFTVKPHSd9ypoI_bduRxkk6mYUdId7y0vdKWMtzaGvG3NyvhgDDd_6jfw8s74Minu7jP14ReoKJCI-rkDXVbMZFTwRkvvtiHU59y5I5ODvdLn1OsiuTYqMLk2_M1KsZyJ9FpuOemGqmS7eWgrLeEmQ8N1c7f8NN-AMx1u3srgw"
            },
            "path": "/public/role/check"
          }
        }
      }
    }
}

test_public_role_check_with_for_token {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJhdWQiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsInN1YiI6ImY6NWJiNmM4N2MtN2M4OC00ZDJiLWFmN2UtNTM0YTJmZWY5NzhkOjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInJvbGVzIjpbeyJyb2xlIjoiQk9PS19DUkVBVE9SIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPTlRFTlRfQ1JFQVRPUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJDT05URU5UX1JFVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPVVJTRV9NRU5UT1IiLCJzY29wZSI6W3sib3JnYW5pc2F0aW9uSWQiOiIwMTM2OTg3ODc5NzUwMzY5MjgxMCJ9XX0seyJyb2xlIjoiUFJPR1JBTV9ERVNJR05FUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJSRVBPUlRfVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6Ik9SR19BRE1JTiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn0seyJvcmdhbmlzYXRpb25JZCI6IjAxNDcxOTIzNTY3ODEyMzQ1Njc4In1dfSx7InJvbGUiOiJQVUJMSUMiLCJzY29wZSI6W119XSwiaXNzIjoiaHR0cHM6Ly9zdW5iaXJkZWQub3JnL2F1dGgvcmVhbG1zL3N1bmJpcmQiLCJuYW1lIjoiZGVtbyIsInR5cCI6IkJlYXJlciIsImV4cCI6MTY0MDIzNjEwMiwiaWF0IjoxNjQwMTQ5NzA1fQ.RpFX4awKLo5kGrJallN5ErsGUOz1G3wuR5ro5egaxRs3V47aXVoLIaxozj0KEOWpaLl1Nn5R7JdFJ7SDWXX9CBR72VFbyW4dx25_1yh49E6Bdjzke0tiZeBWGKT2GqaHfYJ4mXGn-V7nAsY4iQfPL8ftaoYtrEK7hyDf0uM0_pM_tFTVKPHSd9ypoI_bduRxkk6mYUdId7y0vdKWMtzaGvG3NyvhgDDd_6jfw8s74Minu7jP14ReoKJCI-rkDXVbMZFTwRkvvtiHU59y5I5ODvdLn1OsiuTYqMLk2_M1KsZyJ9FpuOemGqmS7eWgrLeEmQ8N1c7f8NN-AMx1u3srgw",
              "x-authenticated-for": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTUifQ.eyJwYXJlbnRJZCI6IjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInN1YiI6IjgwYzM0YzdmLTViYXktNTY0ZS05MDhiLWJmYzA0MTAzODEwZCIsImV4cCI6MTcwMTUxNDA4NSwiaWF0IjoxNjM4NDQyMDg1fQ.skXXt_p2N_0EYQ500Z-xAwdZxoS3MzmVWBhsfSw7ff_QzHciKw21ICDNVnHHOXd_Akf2IA9jUP1lyrBLPRtFrLfYMLjlZB65L2r34QGpBTgkaLhacA_yv7h0neHNHT3D_KO3YKDAdycdAGzTDQZ9BJ1iDtBLc8Qu9VEdRZOQvQf11jotHZf3UEvY3zrpIrghYAfUbTR3kPFp2W_1CJDixWiKgm8IfEJSpzzCHH2RPKPDdyIbY-9eEHGkeTPqtyCNx_vgOLZg5ieJGwyvhH6KRMJ5y1fgXXv0kadZsp7h3nrDSkd3uONStFxdUdIzIIjvJHqjpDFa5NkQbbY0iIULvw"
            },
            "path": "/public/role/check"
          }
        }
      }
    }
}

test_public_role_check_with_empty_for_token {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJhdWQiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsInN1YiI6ImY6NWJiNmM4N2MtN2M4OC00ZDJiLWFmN2UtNTM0YTJmZWY5NzhkOjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInJvbGVzIjpbeyJyb2xlIjoiQk9PS19DUkVBVE9SIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPTlRFTlRfQ1JFQVRPUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJDT05URU5UX1JFVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPVVJTRV9NRU5UT1IiLCJzY29wZSI6W3sib3JnYW5pc2F0aW9uSWQiOiIwMTM2OTg3ODc5NzUwMzY5MjgxMCJ9XX0seyJyb2xlIjoiUFJPR1JBTV9ERVNJR05FUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJSRVBPUlRfVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6Ik9SR19BRE1JTiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn0seyJvcmdhbmlzYXRpb25JZCI6IjAxNDcxOTIzNTY3ODEyMzQ1Njc4In1dfSx7InJvbGUiOiJQVUJMSUMiLCJzY29wZSI6W119XSwiaXNzIjoiaHR0cHM6Ly9zdW5iaXJkZWQub3JnL2F1dGgvcmVhbG1zL3N1bmJpcmQiLCJuYW1lIjoiZGVtbyIsInR5cCI6IkJlYXJlciIsImV4cCI6MTY0MDIzNjEwMiwiaWF0IjoxNjQwMTQ5NzA1fQ.RpFX4awKLo5kGrJallN5ErsGUOz1G3wuR5ro5egaxRs3V47aXVoLIaxozj0KEOWpaLl1Nn5R7JdFJ7SDWXX9CBR72VFbyW4dx25_1yh49E6Bdjzke0tiZeBWGKT2GqaHfYJ4mXGn-V7nAsY4iQfPL8ftaoYtrEK7hyDf0uM0_pM_tFTVKPHSd9ypoI_bduRxkk6mYUdId7y0vdKWMtzaGvG3NyvhgDDd_6jfw8s74Minu7jP14ReoKJCI-rkDXVbMZFTwRkvvtiHU59y5I5ODvdLn1OsiuTYqMLk2_M1KsZyJ9FpuOemGqmS7eWgrLeEmQ8N1c7f8NN-AMx1u3srgw",
              "x-authenticated-for": ""
            },
            "path": "/public/role/check"
          }
        }
      }
    }
}

test_public_role_check_with_keycloak_token {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJqdGkiOiI1MTkwZWVkZS04OTk3LTExZWMtYmE5My02ZjU1NGNiOWIyZDMiLCJleHAiOjE2MzY5OTYyOTUsIm5iZiI6MCwiaWF0IjoxNjM0NDA0Mjk1LCJpc3MiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiJmOjViYjZjODdjLTdjODgtNGQyYi1hZjdlLTUzNGEyZmVmOTc4ZDo2YzIwOTY0Ni04OTk3LTExZWMtOTc0ZS1jM2VhZGFhNjk2MGUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJtb2JpbGUiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI4MmRjNmIyNi04OTk3LTExZWMtYjA5Yy05ZjlmN2Y1YzU5MWQiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbImh0dHBzOi8vc3VuYmlyZGVkLm9yZyJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiIiwibmFtZSI6ImRlbW8iLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJkZW1vIiwiZ2l2ZW5fbmFtZSI6ImRlbW8iLCJlbWFpbCI6ImRlbW9AZGVtby5jb20ifQ.OgNW88vHj8FMdYIqhaOtSVeTm6IbK-eMqjiuRzEWw0xdY1lHLGCWNRQ-i9H5ZjA6YLCVJ0XLxBJqwY-I_fdOy8F8k1uSnOlOCF_-YAD0VBq94wFDQZxvxecz3M1TK-BBzEZI33isCxpxkSSDvkZe-oWrpPYTH0C_pAM6_B8uEzeU-u-77eAiNUhsLipKaVIfbGqli6Z0-M0swdeqCNgDEj98ZJ8OA_ijvEDwrkHu8fRx0SAZgxhMbllO5S_xp5LgF3_X3O2Cy95tk8y4p3bWG-44S4Yr5X0uSZrITMkoTo-kTRY10P4-Zl8zsYgC4HQCecf_h8LgKsdPnsqAdYIm1A"
            },
            "path": "/public/role/check"
          }
        }
      }
    }
}

test_user_and_org_check {
    data.main.allow.allowed
    with input as
    {
      "attributes": {
        "request": {
          "http": {
            "headers": {
              "x-authenticated-user-token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImFjY2Vzc3YxX2tleTEifQ.eyJhdWQiOiJodHRwczovL3N1bmJpcmRlZC5vcmcvYXV0aC9yZWFsbXMvc3VuYmlyZCIsInN1YiI6ImY6NWJiNmM4N2MtN2M4OC00ZDJiLWFmN2UtNTM0YTJmZWY5NzhkOjI4YjBkMDhmLWMyZWEtNDBkMS1iY2QwLThhZTAwZmNhNjZiZSIsInJvbGVzIjpbeyJyb2xlIjoiQk9PS19DUkVBVE9SIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPTlRFTlRfQ1JFQVRPUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJDT05URU5UX1JFVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6IkNPVVJTRV9NRU5UT1IiLCJzY29wZSI6W3sib3JnYW5pc2F0aW9uSWQiOiIwMTM2OTg3ODc5NzUwMzY5MjgxMCJ9XX0seyJyb2xlIjoiUFJPR1JBTV9ERVNJR05FUiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn1dfSx7InJvbGUiOiJSRVBPUlRfVklFV0VSIiwic2NvcGUiOlt7Im9yZ2FuaXNhdGlvbklkIjoiMDEzNjk4Nzg3OTc1MDM2OTI4MTAifV19LHsicm9sZSI6Ik9SR19BRE1JTiIsInNjb3BlIjpbeyJvcmdhbmlzYXRpb25JZCI6IjAxMzY5ODc4Nzk3NTAzNjkyODEwIn0seyJvcmdhbmlzYXRpb25JZCI6IjAxNDcxOTIzNTY3ODEyMzQ1Njc4In1dfSx7InJvbGUiOiJQVUJMSUMiLCJzY29wZSI6W119XSwiaXNzIjoiaHR0cHM6Ly9zdW5iaXJkZWQub3JnL2F1dGgvcmVhbG1zL3N1bmJpcmQiLCJuYW1lIjoiZGVtbyIsInR5cCI6IkJlYXJlciIsImV4cCI6MTY0MDIzNjEwMiwiaWF0IjoxNjQwMTQ5NzA1fQ.RpFX4awKLo5kGrJallN5ErsGUOz1G3wuR5ro5egaxRs3V47aXVoLIaxozj0KEOWpaLl1Nn5R7JdFJ7SDWXX9CBR72VFbyW4dx25_1yh49E6Bdjzke0tiZeBWGKT2GqaHfYJ4mXGn-V7nAsY4iQfPL8ftaoYtrEK7hyDf0uM0_pM_tFTVKPHSd9ypoI_bduRxkk6mYUdId7y0vdKWMtzaGvG3NyvhgDDd_6jfw8s74Minu7jP14ReoKJCI-rkDXVbMZFTwRkvvtiHU59y5I5ODvdLn1OsiuTYqMLk2_M1KsZyJ9FpuOemGqmS7eWgrLeEmQ8N1c7f8NN-AMx1u3srgw"
            },
            "path": "/user/org/check"
          }
        }
      },
      "parsed_body": {
        "request": {
          "content": {
            "channel": "01369878797503692810",
            "createdBy": "28b0d08f-c2ea-40d1-bcd0-8ae00fca66be"
          }
        }
      }
    }
}