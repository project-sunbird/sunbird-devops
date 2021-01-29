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

from os import walk, sep, system, getcwd, makedirs, cpu_count, link, path, makedirs
from argparse import ArgumentParser
from shutil import rmtree, ignore_patterns, copytree
from re import match, compile
from sys import exit
from time import strftime
import concurrent.futures
import errno

# Create temporary directory to copy data
default_snapshot_name = "cassandra_backup" + strftime("%Y-%m-%d-%H%M%S")
tmpdir = getcwd()+sep+default_snapshot_name

parser = ArgumentParser(description="Create a snapshot and create tar ball inside tardirectory")
parser.add_argument("-d", "--datadirectory", metavar="datadir",  default='/var/lib/cassandra/data',
                    help="Path to cassadandra keyspaces. Default /var/lib/cassadra/data")
parser.add_argument("-s", "--snapshotdirectory", metavar="snapdir",  default=tmpdir,
                    help="Path to take cassandra snapshot. Default {}".format(tmpdir))
parser.add_argument("-n", "--snapshotname", metavar="snapshotname",
                    default="cassandra_backup-"+strftime("%Y-%m-%d"),
                    help="Name with which snapshot to be taken. Default {}".format(default_snapshot_name))
parser.add_argument("-t", "--tardirectory", metavar="tardir",
                    default='', help="Path to create the tarball. Disabled by Default")
parser.add_argument("-w", "--workers", metavar="workers",
                    default=cpu_count(), help="Number of workers to use. Default same as cpu cores {}".format(cpu_count()))
parser.add_argument("--disablesnapshot", action="store_true",
                    help="disable taking snapshot, snapshot name can be given via -s flag")
args = parser.parse_args()

tmpdir = args.snapshotdirectory
# Trying to create the directory if not exists
try:
    makedirs(tmpdir+sep+"cassandra_backup")
except OSError as e:
    raise

def customCopy(root, root_target_dir):
    print("copying {} to {}".format(root, root_target_dir))
    copytree(src=root, dst=root_target_dir, copy_function=link, ignore=ignore_patterns('.*'))

def copy():
    '''
    Copying the data sanpshots to the target directory
    '''
    root_levels = args.datadirectory.rstrip('/').count(sep)
    ignore_list = compile(tmpdir+sep+"cassandra_backup"+sep+'(system|system|systemtauth|system_traces|system_schema|system_distributed)')
    # List of the threds running in background
    futures = []
    try:
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as executor:
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
            print("Task completed. Result: {}".format(future.result()))
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
if not args.disablesnapshot:
    # Cleaning all old snapshots
    command = "nodetool clearsnapshot"
    system(command)
    # Taking new snapshot
    command = "nodetool snapshot -t {}".format(args.snapshotname)
    rc = system(command)
    if rc != 0:
        print("Backup failed")
        exit(1)
    print("Snapshot taken.")

# Copying the snapshot to proper folder structure, this is not a copy but a hard link
copy()

# Clearing the snapshot.
# We've the data now available in the copied directory.
command = "nodetool clearsnapshot -t {}".format(args.snapshotname)
print("Clearing snapshot {} ...".format(args.snapshotname))
rc = system(command)
if rc != 0:
    print("Clearing snapshot {} failed".format(args.snapshotname))
    raise
    exit(1)

# Creating tarball
if args.tardirectory:
    print("Making a tarball: {}.tar.gz".format(args.snapshotname))
    command = "cd {} && tar --remove-files -czvf {}/{}.tar.gz *".format(tmpdir, args.tardirectory, args.snapshotname)
    rc = system(command)
    if rc != 0:
        print("Creation of tar failed")
        exit(1)
    # Cleaning up backup directory
    rmtree(tmpdir)
    print("Cassandra backup completed and stored in {}/{}.tar.gz".format(args.tardirectory, args.snapshotname))

