#!/bin/bash

##############################################
# This scipt is designed to restore data to  #
# fresh installation of cassandra            #
##############################################

if [ $# -ne 1 ];then
    echo -e "$0 <path to cassandra backup root dir>"
    exit 1
fi

cass_data_path=/var/lib/cassandra/data
cass_root_path=$1
cass_ip=$(hostname -I | awk '{print $1}')

echo 'Restoring schemas'
for schema in $cass_root_path/schemas/*.schema; do
    cqlsh $cass_ip -e "source '$schema'"
done

echo 'Restoring KeySpaces'

for keyspace in $cass_root_path/keyspace_backup/*;do
    for table in $keyspace/*; do
        sstableloader -d $cass_ip $table
    done
done
