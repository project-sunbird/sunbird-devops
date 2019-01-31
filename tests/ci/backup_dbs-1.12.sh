#!/bin/bash

getTags(){
   declare -A arr
   i=1
   while true
   do
      tag=$(git tag | grep "release-[0-9].*[0-9]$" | sort -V -r | awk -F "." '!($2 in a){i++; a[$2]} (i=='$i'){print $0}' | head -1)
      if [[ $tag != "" ]]; then
         arr[$tag]=$i
         i=$(expr $i + 1)
      else
         break
      fi
   done
   index=${arr["$release"]}
}

checkoutRepo(){
   cd /home/$username
   sudo rm -rf sunbird-devops
   git clone https://github.com/project-sunbird/sunbird-devops.git
   cd sunbird-devops
   getTags
   if [[ $index != "" ]]; then
      git checkout tags/$release -b $release
      echo -e "Installing sunbird on tags $release" | tee $wrapper_log
   else
      git checkout -b $release origin/$release
      echo -e "Installing sunbird on branch $release" | tee -a $wrappper_log
   fi
   cd deploy
}

cassandraBackup(){
echo "Starting cassandra backup" | tee -a $backup_log
python cassandra_backup.py | tee -a $backup_log
if [[ -f cassandra_backup-$(date +%Y-%m-%d).tar.gz ]] && [[ -s cassandra_backup-$(date +%Y-%m-%d).tar.gz ]] ; then
   echo "Cassandra backup successful" | tee -a $backup_log
else
   echo "Cassandra backup failed. Exiting..." | tee -a $backup_log
   exit 1
fi
}

postgresBackup(){
echo "Starting postgres backup" | tee -a $backup_log
bash backup_postgres.sh | tee -a $backup_log
postgres_backup_file=$(ls /tmp/postgresql-backup/)
if [[ -f /tmp/postgresql-backup/$postgres_backup_file ]] && [[ -s /tmp/postgresql-backup/$postgres_backup_file ]]; then
   echo "Postgres backup successful" | tee -a $backup_log
else
   echo "Postgres backup failed. Exiting..." | tee -a $backup_log
   exit 1
fi
}

elasticsearchBackup(){
echo "Staring elasticsearch backup" | tee -a $backup_log
flag=0
snapshot_name="null"
sudo apt install -y jq
sudo bash backup_elasticsearch.sh | tee -a $backup_log
if sudo test -f /etc/elasticsearch/backup/index-0 && sudo test -s /etc/elasticsearch/backup/index-0; then
   snapshot_name=$(sudo cat /etc/elasticsearch/backup/index-0 | jq -r ".snapshots[0].name")
   echo "Elasticsearch backup successful" | tee -a $backup_log
   flag=1
else
   echo "Backup not found. Restarting elasticsearch.." | tee -a $backup_log
   sudo systemctl restart es-1_elasticsearch.service
   sleep 15
   echo "Retrying backup.." | tee -a $backup_log
   sudo bash backup_elasticsearch.sh
fi

if [ $flag -eq 0 ] && sudo test -f /etc/elasticsearch/backup/index-0 && sudo test -s /etc/elasticsearch/backup/index-0; then
snapshot_name=$(sudo cat /etc/elasticsearch/backup/index-0 | jq -r ".snapshots[0].name")
fi

if [[ $snapshot_name == "null" ]]; then
   echo "Elasticsearch backup failed. Exiting..." | tee -a $backup_log
   exit 1
else
   echo "Elasticsearch backup successful" | tee -a $backup_log
fi
}

restoreCassandra(){
echo "Staring cassandra restore" | tee -a $backup_log
arr=($(cqlsh -e "describe keyspaces"))
count=${#arr[@]}
cqlsh -e "drop keyspace dialcodes"
cqlsh -e "drop keyspace portal"
cqlsh -e "drop keyspace sunbird"
cqlsh -e "drop keyspace sunbirdplugin"
tar -xvzf cassandra_backup-$(date +%Y-%m-%d).tar.gz | tee -a $backup_log
cqlsh -f 'cassandra_backup/db_schema.cql' | tee -a $backup_log
python cassandra_restore.py --host $(hostname -i) cassandra_backup | tee -a $backup_log
arr=($(cqlsh -e "describe keyspaces"))
if [[ $count != ${#arr[@]} ]]; then
   echo "Cassandra restore failed. Exiting..." | tee -a $backup_log
   exit 1
else
   echo "Cassandra restore successful" | tee -a $backup_log
fi
}

restorePostgres(){
echo "Starting postgres restore" | tee -a $backup_log
db_count=$(sudo -u postgres psql -c "SELECT count(datname) FROM pg_database" | sed -n 3p | tr -d " ")
sudo -u postgres psql -c "update pg_database set datallowconn = false where datname in ('badger', 'keycloak', 'api_manager', 'quartz')"
sudo -u postgres psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity where pid <> pg_backend_pid()"
sudo -u postgres psql -c "drop database badger"
sudo -u postgres psql -c "drop database keycloak"
sudo -u postgres psql -c "drop database quartz"
sudo -u postgres psql -c "drop database api_manager"
bash restore_postgres.sh $postgres_backup_file | tee -a $backup_log
new_db_count=$(sudo -u postgres psql -c "SELECT count(datname) FROM pg_database" | sed -n 3p | tr -d " ")
if [[ $db_count -ne $new_db_count ]]; then
   echo "Postgres restore failed. Exiting..." | tee -a $backup_log
   exit 1
else
   echo "Postgres restore successful" | tee -a $backup_log
fi
}

restoreElasticsearch(){
echo "Starting elasticsearch restore" | tee -a $backup_log
snapshot_name=$(sudo cat /etc/elasticsearch/backup/index-0 | jq -r ".snapshots[0].name")
indices=$(curl -s -X GET http://$hostip:9200/_cat/indices?v | awk 'NR>1{print $3}' | sort | tr -d "\n")
sudo systemctl restart es-1_elasticsearch.service
sleep 15
bash restore_elasticsearch.sh $snapshot_name | tee -a $backup_log
new_indices=$(curl -s -X GET http://$hostip:9200/_cat/indices?v | awk 'NR>1{print $3}' | sort | tr -d "\n")
if ! [[ "$indices" == "$new_indices" ]]; then
   echo "Elasticsearch restore failed. Exiting..." | tee -a $backup_log
   exit 1
else
   echo "Elsaticsearch restore successful" | tee -a $backup_log
fi
}

release=$1
username=$2
backup_log=/tmp/backuplog.txt
hostip=$(hostname -i)

checkoutRepo
cassandraBackup
postgresBackup
elasticsearchBackup
restoreCassandra
restorePostgres
restoreElasticsearch
