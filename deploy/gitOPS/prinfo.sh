#!/bin/bash
#reading date arguments and github username from command line and converting into string 
d1=$(date -d "$1 00:00:00" +%s) 
d2=$(date -d "$2 23:59:59" +%s)
gitUser=$6
username=$3
password=$4
#reading reponame from jenkins
repo=$(echo $repositories | tr ',' '\n') 

echo "$repo" | while read repo_line
  do
	echo $repo_line
	#getting pull request id list
	prlist=$(curl -s -u $username:$password https://api.github.com/repos/$5/$repo_line/pulls\?state\=all\&page=1\&per_page=10 | jq -r '.[].number')
	echo "REPO_NAME,PR_ID,RAISED_BY,CREATED_AT,STATE,MERGED_BY,MERGED_AT,NO.OF_COMMITS,NO.FILES_CHANGED" > prinfo.csv


echo "$prlist" | while read LINE
	do
		#passing pull request id to get full info
		pr_info=$(curl -s -u $username:$password https://api.github.com/repos/$5/$repo_line/pulls/$LINE | jq -r '.base.repo.name,.user.login,.created_at,.state,.merged_by.login,.merged_at,.commits,.changed_files' | tr '\n' ' ')
		echo $LINE $pr_info | tr ' ' ',' >> tmpFile
		
	done

#reading file and list PR based on start and end date
cat tmpFile | while read pr_line
  do
   	date=$(echo $pr_line | awk -F, '{sub(/T.*/,"",$3);print}' OFS=, | awk -F ',' '{print $4}')
	date=$(date -d "$date" +%s)
		if [[ $date -ge $d1 && $date -le $d2 ]]
		then
			echo $pr_line | awk -F, ' { t = $1; $1 = $2; $2 = t; print; }' OFS=, >> prinfo.csv
		fi
  done

echo "REPO_NAME,PR_ID,RAISED_BY,CREATED_AT,STATE,MERGED_BY,MERGED_AT,NO.OF_COMMITS,NO.FILES_CHANGED" > $gitUser.csv
#grouping PR's by username
if [[ $gitUser == "" ]]; then
	continue;
else
	cat prinfo.csv | awk -v var="$gitUser" -F, '{ if ($3==var) print $0}' >> $gitUser.csv
fi
cp *.csv ../../
done
