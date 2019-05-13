#!/usr/bin/env bash
find . -name "*.properties" | while read fname; do
  job_name=`sed -n "/^job\.name.*$/ p" $fname | sed -n "s/=/\\t/g p" | cut -f 2`
  folder_path=$(dirname `dirname "$fname"`)
  folder_name=`basename $folder_path`
  echo "$folder_name:$job_name:---:stopped"
done > $1
