#!/bin/bash

# Upload build to Firebase
# Usage: upload.sh <file>

#!/bin/bashset -e
echo "Build to upload  "${1}
firebase appdistribution:distribute ${1}  \
    --token {{mobile_firebse_app_distribution_token}}  \
    --app {{mobile_firebse_app_distribution_id}}  \
    --groups {{mobile_firebse_app_distribution_group}}
