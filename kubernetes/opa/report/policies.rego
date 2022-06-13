package policies

import data.common as super

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
  "/report/summary/create": "createReportSummary"
}

getReport {
  acls := ["getReport"]
  roles := ["REPORT_ADMIN", "REPORT_VIEWER", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
}

getReport {
  super.is_an_internal_request
}

listReports {
  acls := ["listReports"]
  roles := ["REPORT_ADMIN", "REPORT_VIEWER", "ORG_ADMIN"]
  super.acls_check(acls)
  super.role_check(roles)
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