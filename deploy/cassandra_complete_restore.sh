#!/bin/bash

##############################################
# This scipt is designed to restore data to  #
# fresh installation of cassandra            #
##############################################

if [ $# -ne 1 ];then
    echo -e "$0 <path to cassandra backup root dir>"
    exit 1
fi

CASS_DATA_PATH=/var/lib/cassandra/data
CASS_ROOT_PATH=$1
CASS_IP=$(hostname -I | awk '{print $1}')

echo 'Restoring schemas'
for schema in $CASS_ROOT_PATH/schemas/*.schema; do
    cqlsh $CASS_IP -e "source '$schema'"
done

echo 'Restoring KeySpaces'

for keyspace in $CASS_ROOT_PATH/keyspace_backup/*;do
    for table in $keyspace/*; do
        sstableloader -d $CASS_IP $table
    done
done
