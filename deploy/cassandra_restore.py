#!/usr/bin/python3

from os import walk, sep
from subprocess import STDOUT, call
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("cassandra_host")
parser.add_argument("snapshotdir")
args = parser.parse_args()

root_levels = args.snapshotdir.count(sep)
for root, dirs, files in walk(args.snapshotdir):
   if root.count(sep) == root_levels + 2:
        print(root)
        call(["sstableloader", "-v", "-d", args.cassandra_host, root], stderr=STDOUT)
