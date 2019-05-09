#!/usr/bin/env bash
./yarn application -list > applist.txt
sed -n "/$1.*$/ p" applist.txt | cut -f 1 > temp.txt
while read in;
do
./yarn application -kill  "$in";
done < temp.txt
rm temp.txt
rm applist.txt