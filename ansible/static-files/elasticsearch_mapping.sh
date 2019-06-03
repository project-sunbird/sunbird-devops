#!/bin/bash

#### Cloning and Changing the directory:
git clone https://github.com/project-sunbird/sunbird-utils.git -b release-1.15
cd sunbird-utils/elasticsearch-util/src/main/resources/indices

#### Creating the new indices:

indices_files=$(ls -l | awk 'NR>1{print $9}' | awk -F"." '{print $1}' | tr "\n" " ")
for file in ${indices_files[@]}
do
        curl  -X PUT http://localhost:9200/${file} -H 'Content-Type: application/json' -d @${file}.json
done

#### Updating the mapping for newly created indices:

echo "#################################################"

cd ../mappings
mapping_files=$(ls -l | awk 'NR>1{print $9}' | awk -F"-" '{print $1}' | tr "\n" " ")

for file in ${mapping_files[@]}
do
        curl  -X PUT http://localhost:9200/${file}/_mapping/_doc -H 'Content-Type: application/json' -d @${file}-mapping.json
done
