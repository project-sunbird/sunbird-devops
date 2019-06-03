#!/usr/bin/env bash
find $2 -name "*.properties" | while read fname; do
  job_name=`sed -n "/^job\.name.*$/ p" $fname | sed -n "s/=/\\t/g p" | cut -f 2`
  folder_path=$(dirname `dirname "$fname"`)
  folder_name=`basename $folder_path`
  if grep -Fwq $job_name $1
  	then
      `sed -i /$job_name/s/^.*\.gz/$folder_name/ $1`;
      `sed -i /$job_name/s/started/restart/ $1`;
  	else
      echo "adding"
    	echo "$folder_name:$job_name:---:stopped" >> $1
  fi
done