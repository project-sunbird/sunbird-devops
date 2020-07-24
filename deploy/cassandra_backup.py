#!/usr/bin/env python3

# Author: Rajesh Rajendran <rjshrjndrn@gmail.com>

'''
Create cassandra snapshot with specified name,
and create tar ball in targetdirectory name

By default

Cassandra data directory : /var/lib/cassandra/data
Snapshot name            : cassandra_backup-YYYY-MM-DD
Backup name              : cassandra_backup-YYYY-MM-DD.tar.gz

usage: script snapshot_name

eg: ./cassandra_backup.py

for help ./cassandra_backup.py -h
'''

from os import walk, sep, system, getcwd, makedirs
from argparse import ArgumentParser
from shutil import rmtree, ignore_patterns, copytree
from re import match, compile
from sys import exit
from tempfile import mkdtemp
from time import strftime
import concurrent.futures

parser = ArgumentParser(description="Create a snapshot and create tar ball inside tardirectory")
parser.add_argument("-d", "--datadirectory", metavar="datadir",  default='/var/lib/cassandra/data',
                    help="Path to cassadandra keyspaces. Default /var/lib/cassadra/data")
parser.add_argument("-s", "--snapshotname", metavar="snapshotname",
                    default="cassandra_backup-"+strftime("%Y-%m-%d"),
                    help="Name with which snapshot to be taken. Default {}".format("cassandra_backup-"+strftime("%Y-%m-%d")))
parser.add_argument("-t", "--tardirectory", metavar="tardir",
                    default=getcwd(), help="Path to create the tarball. Default {}".format(getcwd()))
parser.add_argument("--disablesnapshot", action="store_true",
                    help="disable taking snapshot, snapshot name can be given via -s flag")
args = parser.parse_args()

# Create temporary directory to copy data
tmpdir = mkdtemp()
makedirs(tmpdir+sep+"cassandra_backup")

def customCopy(root, root_target_dir):
    print("copying {} to {}".format(root, root_target_dir))
    copytree(src=root, dst=root_target_dir, ignore=ignore_patterns('.*'))

def copy():
    '''
    Copying the data sanpshots to the target directory
    '''
    root_levels = args.datadirectory.rstrip('/').count(sep)
    ignore_list = compile(tmpdir+sep+"cassandra_backup"+sep+'(system|system|systemtauth|system_traces|system_schema|system_distributed)')
    # List of the threds running in background
    futures = []
    try:
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            for root, dirs, files in walk(args.datadirectory):
                root_target_dir = tmpdir+sep+"cassandra_backup"+sep+sep.join(root.split(sep)[root_levels+1:-2])
                if match(ignore_list, root_target_dir):
                    continue
                if root.split(sep)[-1] == args.snapshotname:
                    # Keeping copy operation in background with threads
                    tmp_arr = [root, root_target_dir]
                    futures.append( executor.submit( lambda p: customCopy(*p), tmp_arr))
    except Exception as e:
        print(e)
    # Checking status of the copy operation
    for future in concurrent.futures.as_completed(futures):
        try:
            print("Task completed for ...")
            print(future.result())
        except Exception as e:
            print(e)

# Creating schema
command = "cqlsh -e 'DESC SCHEMA' > {}/cassandra_backup/db_schema.cql".format(tmpdir)
rc = system(command)
if rc != 0:
    print("Couldn't backup schema, exiting...")
    exit(1)
print("Schema backup completed. saved in {}/cassandra_backup/db_schema.sql".format(tmpdir))
# Default value for snapshot
rc = 0

# Creating snapshots
if not args.disablesnapshot:
    # Cleaning all old snapshots
    command = "nodetool clearsnapshot"
    system(command)
    # Taking new snapshot
    command = "nodetool snapshot -t {}".format(args.snapshotname)
    rc = system(command)
if rc == 0:
    if not args.disablesnapshot:
        print("Snapshot taken.")
    copy()
    print("Making a tarball: {}.tar.gz".format(args.snapshotname))
    command = "cd {} && tar -czvf {}/{}.tar.gz *".format(tmpdir, args.tardirectory, args.snapshotname)
    system(command)
    # Cleaning up backup directory
    rmtree(tmpdir)
    print("Cassandra backup completed and stored in {}/{}.tar.gz".format(args.tardirectory, args.snapshotname))

