#!/usr/bin/env python3

'''
 Please run nodetool snapshot -t <snap_name> before running the script

 script to copy cassandra snaps to a remote dir
 usage script  --datadir /path/to/datadir \
               --snapshotname snapshot name
               --targetdir /path/targetdir
 eg: ./cassandra_copy_backup.py --datadir /var/lib/cassandra/data \
                                --snapshotname my_snapshot
                                --targetdir /backups/cassandra/$(date +%Y-%m-%d)
'''

from os import path, walk, sep
import argparse
from shutil import rmtree, ignore_patterns, copytree
from re import match, compile

parser = argparse.ArgumentParser()
parser.add_argument("datadir")
parser.add_argument("snapshotname")
parser.add_argument("targetdir")
args = parser.parse_args()

# Removing target dir
if path.exists(args.targetdir):
    rmtree(args.targetdir)

root_target_dir = args.targetdir.split(sep)[-1]
root_levels = args.datadir.count(sep)
ignore_list = compile(args.targetdir+sep+'(system|system|systemtauth|system_traces|system_schema|system_distributed)')

try:
    for root, dirs, files in walk(args.datadir):
        root_target_dir=args.targetdir+sep+sep.join(root.split(sep)[root_levels+1:-2])
        if match(ignore_list, root_target_dir):
            continue
        if root.split(sep)[-1] == args.snapshotname:
            copytree(src=root, dst=root_target_dir, ignore=ignore_patterns('.*'))
except Exception as e:
    print(e)
