#!/bin/sh
postgresql_backup_dir=/tmp/postgresql-backup
if [ -f $postgresql_backup_dir ]
then
    echo “directory already exists”
else
    mkdir $postgresql_backup_dir
fi

postgresql_backup_gzip_file_name="postgresql_backup_`date +%Z-%Y-%m-%d-%H-%M-%S`.txt"
postgresql_backup_gzip_file_path=$postgresql_backup_dir/$postgresql_backup_gzip_file_name
sudo su postgres -c 'pg_dumpall' > $postgresql_backup_gzip_file_path