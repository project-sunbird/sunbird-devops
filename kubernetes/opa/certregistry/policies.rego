package policies

import data.common as super

urls_to_action_mapping := {   
  "/certs/v1/registry/download": "downloadRegCertificate",
  "/certs/v2/registry/download": "downloadRegCertificateV2"
}

downloadRegCertificate {
  super.public_role_check
}

downloadRegCertificateV2 {
  super.public_role_check
}