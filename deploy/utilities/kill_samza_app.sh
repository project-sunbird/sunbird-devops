#!/bin/bash
# Author S M Y <smy.altamash@gmail.com>
# Kill All the Samza Jobs

for id in $(/usr/local/hadoop/bin/yarn application --list | column -t | awk 'NR>2{print $1}' | tr "\n" " ");
do
	echo "ID is $id"
	/usr/local/hadoop/bin/yarn application -kill $id
	sleep 1
done
echo -e "\n--------------------------------------------------------------------------\n"
echo "The Overall status of yarn is as follows:"
/usr/local/hadoop/bin/yarn application --list | awk '{print $1 " " $2 " " $6 " " $7 " " $9}' | column -t
