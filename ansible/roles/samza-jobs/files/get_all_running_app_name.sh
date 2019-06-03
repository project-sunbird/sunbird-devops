#!/usr/bin/env bash
job_names=(`./yarn application -list | cut -f 2 | sed 1,'/Application-Name/'d | sed 's/_1$//'`)
job_ids=(`./yarn application -list | cut -f 1 | sed 1,'/Application-Id/'d`)
count=${#job_names[@]}
for (( i=0; i<${count}; i++ ));
do
	job_name=${job_names[i]}
	job_id=${job_ids[i]}
	`sed -i /$job_name/s/stopped/started/g $1`
	`sed -i /$job_name/s/---/$job_id/g $1`
done
