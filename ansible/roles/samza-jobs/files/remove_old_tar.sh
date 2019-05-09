#!/usr/bin/env bash
cat $1 | awk -F':' '{print $1}' > tmp.txt
DIRS=`ls -l $2/extract/ | egrep '^d'| awk '{print $9}'`
for dir in $DIRS
do
  if ! grep -Fxq $dir tmp.txt
  then
     rm -rf $dir
     rm $2/$dir
  fi
done
rm tmp.txt