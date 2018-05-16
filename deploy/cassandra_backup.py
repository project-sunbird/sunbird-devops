#!/usr/bin/env python3

# Author: Rajesh Rajendran <rjshrjndrn@gmail.com>

'''
Create a snapshot and create tar ball in targetdirectory name

usage: script  /path/to/datadirectory snapshot_name /path/targetdirectory

eg: ./cassandra_backup.py /var/lib/cassandra/data my_snapshot /backups/cassandra/$(date +%Y-%m-%d)
'''

from os import path, walk, sep, system
from argparse import ArgumentParser 
from shutil import rmtree, ignore_patterns, copytree
from re import match, compile
from sys import exit

parser = ArgumentParser(description="Create a snapshot and create tar ball in targetdirectory name")
parser.add_argument("datadirectory", help="path to datadirectory of cassandra")
parser.add_argument("snapshotname", help="name in which you want to take the snapshot")
parser.add_argument("targetdirectory", help="name of tarball you want to create")
args = parser.parse_args()

if path.exists(args.targetdirectory):
    print("\033[91m Directory {} exists; exiting without backing up cassandra...".format(args.targetdirectory))
    exit(1)

def copy():
    '''
    Copying the data sanpshots to the target directory
    '''
    print("copying")
    root_target_dir = args.targetdirectory.split(sep)[-1]
    print(root_target_dir)
    root_levels = args.datadirectory.count(sep)
    ignore_list = compile(args.targetdirectory+sep+'(system|system|systemtauth|system_traces|system_schema|system_distributed)')

    try:
        for root, dirs, files in walk(args.datadirectory):
            root_target_dir=args.targetdirectory+sep+sep.join(root.split(sep)[root_levels+1:-2])
            if match(ignore_list, root_target_dir):
                continue
            if root.split(sep)[-1] == args.snapshotname:
                copytree(src=root, dst=root_target_dir, ignore=ignore_patterns('.*'))
    except Exception as e:
        print(e)

# Creating snapshots
command = "nodetool snapshot -t {}".format(args.snapshotname)
rc = system(command)
if rc == 0:
    print("Snapshot taken. Copying to target dir")
    copy()
    print("Making a tarball")
    command = "tar -czvf {}.tar.gz {}".format(args.targetdirectory,args.targetdirectory)
    system(command)

# Cleaning up backup directory
print("Cleaning up temporary directory")
rmtree(args.targetdirectory)
print("Cassandra backup completed and stored as {}.tar.gz".format(args.targetdirectory))
