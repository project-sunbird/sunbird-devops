#!/bin/sh
backup_path=/etc/elasticsearch/backup
es_ip=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')

curl 172.31.0.239:9200/_cat/indices?v | awk '{print $3}' | awk 'NR>1' > ~/index.txt 

while read line;
do
        curl -XDELETE http://$es_ip:9200/$line
done < ~/index.txt

rm -rf ~/index.txt

snapshot_id=$1

curl -XPOST "http://$es_ip:9200/_snapshot/my_backup/$snapshot_id/_restore"

echo $(curl http://$es_ip:9200/_cat/indices?v)