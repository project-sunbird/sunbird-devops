package policies

import data.common as super
import input.attributes.request.http as http_request

x_authenticated_user_token := http_request.headers["x-authenticated-user-token"]

urls_to_action_mapping := {
  "/report/get": "getReport",
  "/report/list": "listReports",
  "/report/create": "createReport",
  "/report/delete": "deleteReport",
  "/report/update": "updateReport",
  "/report/publish": "publishReport",
  "/report/retire": "retireReport",
  "/report/summary": "getReportSummary",
  "/report/summary/list": "listReportSummary",
  "/report/summary/create": "createReportSummary",
  "/report/datasets/get": "getReportDatasets"
}

getReport {
  super.public_role_check
}

getReport {
  not x_authenticated_user_token
}

getReport {
  super.is_an_internal_request
}

listReports {
  super.public_role_check
}

listReports {
  not x_authenticated_user_token
}

createReport {
  acls := ["createReport"]
  roles := ["REPORT_ADMIN", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
  input.parsed_body.request.report.createdby == super.userid
}

createReport {
  super.is_an_internal_request
}

deleteReport {
  acls := ["deleteReport"]
  roles := ["REPORT_ADMIN", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

updateReport {
  acls := ["updateReport"]
  roles := ["REPORT_ADMIN", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

updateReport {
  super.is_an_internal_request
}

publishReport {
  acls := ["publishReport"]
  roles := ["REPORT_ADMIN", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

retireReport {
  acls := ["retireReport"]
  roles := ["REPORT_ADMIN", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

getReportSummary {
  acls := ["getReportSummary"]
  roles := ["REPORT_ADMIN", "REPORT_VIEWER", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

listReportSummary {
  acls := ["listReportSummary"]
  roles := ["REPORT_ADMIN", "REPORT_VIEWER", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

createReportSummary {
  acls := ["createReportSummary"]
  roles := ["REPORT_ADMIN", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
  input.parsed_body.request.summary.createdby == super.userid
}

getReportDatasets {
  super.public_role_check
}

getReportDatasets {
  not x_authenticated_user_token
}