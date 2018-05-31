#!/usr/bin/python3

# Author: Rajesh Rajendran <rjshrjndrn@gmail.com>.

"""
To restore the cassandra database snapshot
usage: ./cassandra_restore.py -d ipaddress snapshot_directory_name
"""

from os import walk, sep
from subprocess import STDOUT, call
from argparse import ArgumentParser, SUPPRESS
from socket import gethostbyname, gethostname

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
