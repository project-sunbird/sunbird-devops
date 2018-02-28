#!/bin/sh
backup_path=/etc/elasticsearch/backup
es_ip=10.2.1.5

if [ -f $backup_path ]
then
	echo "directory exists"
else
	mkdir -p /etc/elasticsearch/backup
fi 

cat >> /etc/elasticsearch/es-1/elasticsearch.yml << EOF
path.repo: ["/etc/elasticsearch/backup"]
EOF

/usr/share/elasticsearch/bin/elasticsearch \
                                    -p /var/run/elasticsearch/10.2.1.5-es-1/elasticsearch.pid \
                                    --quiet \
                                    -Edefault.path.logs=${LOG_DIR} \
                                    -Edefault.path.data=${DATA_DIR} \
                                    -Edefault.path.conf=${CONF_DIR}

chown -R elasticsearch:elasticsearch $backup_path



curl -XPUT 'http://$es_ip:9200/_snapshot/my_backup' -d {
  "type": "fs",
  "settings": {
     "location": "$backup_path",
     "compress": true
  }
}'



curl -XPUT "$es_ip:9200/_snapshot/my_backup/snapshot_1?wait_for_completion=true"

