#!/bin/bash

cass_data_path=/var/lib/cassandra/data

mkdir keyspace_backup schemas

echo 'Clearing old snapshots'
nodetool clearsnapshot

nodetool flush

echo 'Backing up schema and keyspaces'
ls $Cass_data_path | grep -v system* > dbs.log

while read keyspace
do
    cp -rf $cass_data_path/$keyspace keyspace_backup/
    cqlsh -e "DESC $keyspace" > schemas/$keyspace.schema
done < dbs.log

echo 'creating tar'

tar -cvf complete_cassandra_bakup_$(date +%Y%m%d).tar keyspace_backup schemas dbs.log

if [ $# -eq 0 ];then
    rm -rf keyspace_backup schemas dbs.log
fi
