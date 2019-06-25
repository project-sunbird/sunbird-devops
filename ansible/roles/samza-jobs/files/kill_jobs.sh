#!/usr/bin/env bash
cat $1 | while read LINE
do
 application_id=`echo $LINE | awk -F':' '{print $3}'`;
 status=`echo $LINE | awk -F':' '{print $4}'`;
 
 if [ "$status" == "restart" ]
 then
  ./yarn application -kill $application_id
 fi
done