#!/usr/bin/env python3

# Author: Rajesh Rajendran <rjshrjndrn@gmail.com>

'''
Create a snapshot and create tar ball in targetdirectory name

usage: script  /path/to/datadirectory snapshot_name

eg: ./cassandra_backup.py /var/lib/cassandra/data my_snapshot
'''

from os import path, walk, sep, system, getcwd, makedirs
from argparse import ArgumentParser 
from shutil import rmtree, ignore_patterns, copytree
from re import match, compile
from sys import exit
from tempfile import mkdtemp

parser = ArgumentParser(description="Create a snapshot and create tar ball inside tardirectory")
parser.add_argument("datadirectory", help="path to datadirectory of cassandra")
parser.add_argument("snapshotname", help="name in which you want to take the snapshot")
parser.add_argument("-t","--tardirectory", metavar="tardir",  default=getcwd(), help="path to create the tarball. Default {}".format(getcwd()))
args = parser.parse_args()

# Create temporary directory to copy data
tmpdir=mkdtemp()
makedirs(tmpdir+sep+"cassandra_backup")

def copy():
    '''
    Copying the data sanpshots to the target directory
    '''
    root_levels = args.datadirectory.count(sep)
    ignore_list = compile(tmpdir+sep+"cassandra_backup"+sep+'(system|system|systemtauth|system_traces|system_schema|system_distributed)')

    try:
        for root, dirs, files in walk(args.datadirectory):
            root_target_dir=tmpdir+sep+"cassandra_backup"+sep+sep.join(root.split(sep)[root_levels+1:-2])
            if match(ignore_list, root_target_dir):
                continue
            if root.split(sep)[-1] == args.snapshotname:
                copytree(src=root, dst=root_target_dir, ignore=ignore_patterns('.*'))
    except Exception as e:
        print(e)

# Creating schema
command = "cqlsh -e 'DESC SCHEMA' > {}/cassandra_backup/db_schema.cql".format(tmpdir)
rc = system(command)
if rc != 0:
    print("Couldn't backup schema, exiting...")
    exit(1)
print("Schema backup completed. saved in {}/cassandra_backup/db_schema.sql".format(tmpdir))
# Creating snapshots
command = "nodetool snapshot -t {}".format(args.snapshotname)
rc = system(command)
if rc == 0:
    print("Snapshot taken.")
    copy()
    print("Making a tarball: {}.tar.gz".format(args.snapshotname))
    command = "cd {} && tar -czvf {}/{}.tar.gz *".format(tmpdir, args.tardirectory, args.snapshotname)
    system(command)
    # Cleaning up backup directory
    rmtree(tmpdir)
    print("Cassandra backup completed and stored in {}/{}.tar.gz".format(args.tardirectory,args.snapshotname))
