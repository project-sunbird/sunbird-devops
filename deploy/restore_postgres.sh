#!/bin/bash
postgresql_backup_dir=/tmp/postgresql-backup

backupfile=$1

sqlfile="${backupfile//.gz}"

gunzip $postgresql_backup_dir/$backupfile -d $postgresql_backup_dir/$sqlfile 

postgresql_backup_gzip_file_path=$postgresql_backup_dir/$sqlfile
sudo su postgres -c "psql -f $postgresql_backup_gzip_file_path postgres"