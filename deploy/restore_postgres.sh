#!/bin/bash

## Temporary backup directory
postgresql_backup_dir=/tmp/postgresql-backup

#Provide backup filename as ex: sudo bash restore_postgres.sh postgresql_backup_UTC-2018-04-08-21-16-05.sql.gz
backupfile=$1

sqlfile="${backupfile//.gz}"

gunzip $postgresql_backup_dir/$backupfile -d $postgresql_backup_dir/$sqlfile 

postgresql_backup_gzip_file_path=$postgresql_backup_dir/$sqlfile

# restore process
sudo su postgres -c "psql -f $postgresql_backup_gzip_file_path postgres"