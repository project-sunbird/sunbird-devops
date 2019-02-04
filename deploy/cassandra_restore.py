#!/usr/bin/python3

# Author: Rajesh Rajendran <rjshrjndrn@gmail.com>.

"""

This script will restore complete backup from the backup data folder.

To restore the cassandra database snapshot

1. If it's an old cassandra instance, do the following else continue to step 2
   a. stop cassandra
   b. delete the data (usually sudo rm -rf /var/lib/cassandra/*)
   c. start cassandra

2. Restore the schema
   cqlsh -e "source 'backup_dir/db_schema.cql';"

3. Restore the data
   usage: ./cassandra_restore.py --host <ip of the server> snapshot_directory_name

"""

from os import walk, sep
from subprocess import STDOUT, call
from argparse import ArgumentParser

parser = ArgumentParser(description="Restore cassandra snapshot")
parser.add_argument("--host", default="127.0.0.1", help="ip address of cassandra instance. \
        Default: 127.0.0.1")
parser.add_argument("snapshotdir", metavar="snapshotdirectory", help="snapshot directory name or path")
args = parser.parse_args()

root_levels = args.snapshotdir.count(sep)
for root, dirs, files in walk(args.snapshotdir):
    if root.count(sep) == root_levels + 2:
        print(root)
        call(["sstableloader", "-v", "-d", args.host, root], stderr=STDOUT)
