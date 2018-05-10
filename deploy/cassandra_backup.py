#!/usr/bin/env python3

'''
Author: Rajesh Rajendran <rjshrjndrn@gmail.com>

Create a snapshot and create tar ball in targetdir name

usage: script  --datadir /path/to/datadir \
              --snapshotname snapshot name \
              --targetdir /path/targetdir
eg: ./cassandra_backup.py --datadir /var/lib/cassandra/data \
                          --snapshotname my_snapshot \
                          --targetdir /backups/cassandra/$(date +%Y-%m-%d)
'''

from os import path, walk, sep, system
from argparse import ArgumentParser 
from shutil import rmtree, ignore_patterns, copytree
from re import match, compile
from sys import exit

parser = ArgumentParser()
parser.add_argument("--datadir")
parser.add_argument("--snapshotname")
parser.add_argument("--targetdir")
args = parser.parse_args()

if path.exists(args.targetdir):
    print("\033[91m Target directory {} exists; exiting without backing up cassandra...".format(args.targetdir))
    exit(1)

def copy():
    '''
    Copying the data sanpshots to the target directory
    '''
    print("copying")
    root_target_dir = args.targetdir.split(sep)[-1]
    print(root_target_dir)
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

# Creating snapshots
command = "nodetool snapshot -t {}".format(args.snapshotname)
rc = system(command)
if rc == 0:
    print("Snapshot taken. Copying to target dir")
    copy()
    print("Making a tarball")
    command = "tar -czvf {}.tar.gz {}".format(args.targetdir,args.targetdir)
    system(command)
