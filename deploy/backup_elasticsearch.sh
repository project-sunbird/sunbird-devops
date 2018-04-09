#!/bin/sh
backup_path=/etc/elasticsearch/backup
es_ip=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')

if [ -d $backup_path ];
then
  echo "directory exists"
else
  mkdir -p /etc/elasticsearch/backup
fi 

temp=$(grep "path.repo:" /etc/elasticsearch/es-1/elasticsearch.yml)

if [ $? -ne 0 ]; then

 cat >> /etc/elasticsearch/es-1/elasticsearch.yml << EOF
path.repo: ["/etc/elasticsearch/backup"]
EOF

fi

chown -R elasticsearch:elasticsearch $backup_path


echo $es_ip

curl -XPUT http://$es_ip:9200/_snapshot/my_backup -d '{
  "type": "fs",
  "settings": {
     "location": "'$backup_path'",
     "compress": true
  }
}'



timestamp=`date '+%d_%m_%Y%H%M%S'`

curl -XPUT http://$es_ip:9200/_snapshot/my_backup/snapshot_$timestamp?wait_for_completion=true