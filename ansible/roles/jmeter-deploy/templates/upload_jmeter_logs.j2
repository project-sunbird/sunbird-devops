#!/bin/sh

IP_ADDR=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
scenario_id=$1
INSTANCE=`echo $IP_ADDR | sed 's/\.//g'`
LOG_FILE_NAME="${scenario_id}_${INSTANCE}"
cd /mnt/data/benchmark/logs/$scenario_id
cp -r logs "${LOG_FILE_NAME}_logs"
tar -czvf "${LOG_FILE_NAME}_logs.tar.gz" "${LOG_FILE_NAME}_logs"
aws s3 cp "/mnt/data/benchmark/logs/$scenario_id/${LOG_FILE_NAME}_logs.tar.gz" s3://ekstep-backups-sandbox/lp_service_logs/LP-PE/ --region ap-south-1
rm -rf ${LOG_FILE_NAME}_log*