#!/bin/bash

###-----------------------------------------------------###
# Author:: Kaliraja
# Description:: This script is to query the api calls data 
# from log-es and send as a report to email and uploading
# the same to azure storage.
###-----------------------------------------------------###


#date variables
prev_day=`date "+%s" -d "yesterday 03:30:00"`
today=`date "+%s" -d "today 03:30:00"`
date=`date +"%m-%d-%Y"`

#prev_day=`date "+%s" -d "yesterday -7 day 03:30:00"`
#today=`date "+%s" -d "yesterday -6 day 03:30:00"`
#date=`date +%m-%d-%y --date="yesterday -6 day" | sed 's/19/2019/'`

#api variable
contentsearch="/api/composite/v1/search"
contentread="/api/content/v1/read/"
telemetry="/api/data/v1/telemetry"
registermobile="/api/api-manager/v1/consumer/mobile_device/credential/register"

#filename variable
contentsearch_filename=contentsearch-$date.txt
contentread_filename=contentread-$date.txt
telemetry_filename=telemetry-$date.txt
mobiledevice_registerfilename=registermobile-$date.txt

#sedngrid variable
sguser="$1"
sgpass="$2"
container_name="$3"
account_name="$4"
storage_key="$5"


query(){
    curl -H 'Content-Type:application/json' -s -XPOST 'localhost:9200/logstash-*/_search?pretty' -d '{"query":{"bool":{"must":{"query_string":{"analyze_wildcard":true,"query":"\"'$1'\""}},"filter":{"bool":{"must":[{"range":{"@timestamp":{"gte":"'"$prev_day"'","lte":"'"$today"'","format":"epoch_second"}}}],"must_not":[]}}}},"size":0,"aggs":{"2":{"date_histogram":{"field":"@timestamp","interval":"15m","time_zone":"Asia/Kolkata","min_doc_count":1,"extended_bounds":{"min": 0,"max": 500}}}}}' |  jq -r '.aggregations."2".buckets[]|.key_as_string+" "+ (.doc_count|tostring)' | column -t > $2
}

#Executing content search query

query $contentsearch $contentsearch_filename

#Execurting the contentread query

query $contentread $contentread_filename

#Executing the telemetry query

query $telemetry $telemetry_filename

#Executing the registermobiledevice query

query $registermobile $mobiledevice_registerfilename

#sending an email with an attachment

curl https://api.sendgrid.com/api/mail.send.json \
 {{ api_report_mailing_list }} -F subject="Data for Diksha api calls" \
 -F text="Data" --form-string html="<strong>Hi Team, PFA.</strong>" \
 -F from=reports@diksha.in -F api_user="$sguser" -F api_key="$sgpass" \
 -F files\[contentsearch.txt\]=@contentsearch-$date.txt -F files\[contentread.txt\]=@contentread-$date.txt -F files\[telemetry.txt]=@telemetry-$date.txt -F files\[registermobile.txt]=@registermobile-$date.txt


# uploading  the reports to storage

az storage blob upload \
--container-name $container_name \
--file contentsearch-$date.txt \
--name contentsearch-$date.txt  \
--account-name $account_name  \
--account-key $storage_key

az storage blob upload \
--container-name $container_name \
--file contentread-$date.txt \
--name contentread-$date.txt  \
--account-name $account_name  \
--account-key $storage_key


az storage blob upload \
--container-name $container_name \
--file telemetry-$date.txt \
--name telemetry-$date.txt  \
--account-name $account_name  \
--account-key $storage_key

az storage blob upload \
--container-name $container_name \
--file registermobile-$date.txt \
--name registermobile-$date.txt  \
--account-name $account_name  \
--account-key $storage_key


# deleting files

rm *-$date.txt
