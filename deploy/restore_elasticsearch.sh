#!/bin/sh
backup_path=/etc/elasticsearch/backup
es_ip=$(hostname -i)
#es_ip=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')

#Removing exiting indexes 
curl http://"$es_ip":9200/_cat/indices?v | awk '{print $3}' | awk 'NR>1' > ~/index.txt 

while read line;
do
	curl -XDELETE http://"$es_ip":9200/$line
done < ~/index.txt

rm -rf ~/index.txt

#Provide snapshot id for restore of elasticsearch ex: ./restore.sh snapshot_09_04_2018105317, snapshot ID can be found in /etc/elasticsearch/backup/index-0
snapshot_id=$1

curl -XPOST http://"$es_ip":9200/_snapshot/my_backup/$snapshot_id/_restore

curl http://"$es_ip":9200/_cat/indices?v
