#!/bin/sh
backup_path=/etc/elasticsearch/backup
es_ip=$(hostname -i)
#es_ip=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')

#Creating backup folder
if [ -d $backup_path ];
then
  echo "directory exists"
else
  mkdir -p $backup_path
fi

#Adding backup path repo to elasticsearch config
temp=$(grep "path.repo:" /etc/elasticsearch/es-1/elasticsearch.yml)

if [ $? -ne 0 ]; then

 cat >> /etc/elasticsearch/es-1/elasticsearch.yml << EOF
path.repo: ["$backup_path"]
EOF

fi

#Changing permissions to backup path
chown -R elasticsearch:elasticsearch $backup_path

#Creating Indexes name for backup
curl -XPUT http://"$es_ip":9200/_snapshot/my_backup -d '{
  "type": "fs",
  "settings": {
     "location": "'$backup_path'",
     "compress": true
  }
}'


#Taking Snapshot of elasticsearch with timestamp
timestamp=`date '+%d_%m_%Y%H%M%S'`

curl -XPUT http://"$es_ip":9200/_snapshot/my_backup/snapshot_$timestamp?wait_for_completion=true

