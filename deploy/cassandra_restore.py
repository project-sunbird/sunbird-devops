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
   usage: python cassandra_restore.py

"""

from os import walk, sep
from subprocess import STDOUT, call
from argparse import ArgumentParser
import socket
parser = ArgumentParser(description="Restore cassandra snapshot")
parser.add_argument("--host", default=socket.getfqdn(), metavar="< Default: "+socket.getfqdn()+" >", help="ip address of cassandra instance")
parser.add_argument("--snapshotdir", default="cassandra_backup", metavar="< Default: cassandra_backup >", help="snapshot directory name or path")
args = parser.parse_args()

# Unix autocompletion for directory will append '/', which will break restore process
snap_dir = args.snapshotdir.rstrip('/')
root_levels = snap_dir.count(sep)
for root, dirs, files in walk(snap_dir):
    if root.count(sep) == root_levels + 2:
        print(root)
        call(["sstableloader", "-v", "-d", args.host, root], stderr=STDOUT)
