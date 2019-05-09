#!/usr/bin/env bash
folder_path=$2
cat $1 | while read LINE
do
 dir_name=`echo $LINE | awk -F':' '{print $1}'`;
 job_name=`echo $LINE | awk -F':' '{print $2}'`;
 application_id=`echo $LINE | awk -F':' '{print $3}'`;
 status=`echo $LINE | awk -F':' '{print $4}'`;
 properties_path="$folder_path/$dir_name/config/*.properties"
 config_file_path=`ls -d $properties_path`
 if [ "$status" == "stopped" ] || [ "$status" == "restart" ]
 then
   ./$dir_name/bin/run-job.sh --config-factory=org.apache.samza.config.factories.PropertiesConfigFactory --config-path=file:///$config_file_path
 fi
done