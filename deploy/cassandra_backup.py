
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

from argparse import ArgumentParser
import concurrent.futures
from os import cpu_count, getcwd, link, makedirs, makedirs, sep, system, walk, path
from re import compile, match
from shutil import copytree, ignore_patterns, rmtree
import socket
from subprocess import check_output
from sys import exit
from time import strftime


'''
Returns the ip address of current host machine
'''
def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        print("Couldn't get the correct, please pass the current node's cassandra ip address using flag '--host <ip address>'")
        raise
    finally:
        s.close()
    return  str(IP)

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
parser.add_argument("--host", default=get_ip(), metavar="< Default: "+get_ip()+" >", help="ip address of cassandra instance. Used to take the token ring info. If the ip address is not correct, Please update the ip address, else your token ring won't be correct.")
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

# Names of the keyspaces to take schema backup
ignore_keyspace_names = []

def copy():
    '''
    Copying the data sanpshots to the target directory
    '''
    root_levels = args.datadirectory.rstrip('/').count(sep)
    # List of system keyspaces, which we don't need.
    # We need system_schema keyspace, as it has all the keyspace,trigger,types information.
    ignore_keyspaces = ["system", "system_auth", "system_traces", "system_distributed", "lock_db"]
    #  ignore_list = compile('^'+tmpdir+sep+"cassandra_backup"+sep+'(system|system_auth|system_traces|system_distributed|lock_db)/.*$')
    ignore_list = compile('^'+tmpdir+sep+"cassandra_backup"+sep+"("+"|".join(ignore_keyspaces)+')/.*$')
    # List of the threds running in background
    futures = []
    try:
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as executor:
            for root, _, _ in walk(args.datadirectory):
                keyspace = sep+sep.join(root.split(sep)[root_levels+1:-2])
                # We don't need tables and other inner directories for keyspace.
                if len(keyspace.split('/')) != 3:
                    continue
                root_target_dir = tmpdir+sep+"cassandra_backup"+keyspace
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

keyspaces_schema_dict = {}
def create_schema(schema_file):
    cmd = "cqlsh -e 'SELECT * from system_schema.keyspaces;' | tail -n +4 | head -n -2"
    output = check_output('{}'.format(cmd), shell=True).decode().strip()
    for line in output.split('\n'):
        tmpline = line.split("|")
        keyspaces_schema_dict[tmpline[0].strip()] = {"durable_writes": tmpline[1].strip(),"replication": tmpline[2].strip()}

    # Creating table schema
    for root, _, files in walk(tmpdir):
        for file in files:
            if file.endswith(".cql"):
                with open(path.join(root, file),'r') as f:
                    with open(schema_file,'a') as w:
                        w.write(f.read())
                        w.write('\n')

# Creating complete schema
# For `ALTER DROP COLUMN`,
# This schema will have issues.
# So you'll have to create and drop the column.
# For details about that table/column, look at snapshot_table_schema.sql
command = "cqlsh -e 'DESC SCHEMA' > {}/cassandra_backup/complete_db_schema.cql".format(tmpdir)
rc = system(command)
if rc != 0:
    print("Couldn't backup schema, exiting...")
    exit(1)
print("Schema backup completed. saved in {}/cassandra_backup/complete_db_schema.sql".format(tmpdir))

# Backing up tokenring
command = """ nodetool ring | grep """ + get_ip() + """ | awk '{print $NF ","}' | xargs | tee -a """ + tmpdir + """/cassandra_backup/tokenring.txt """ #.format(args.host, tmpdir)
print(command)
rc = system(command)
if rc != 0:
    print("Couldn't backup tokenring, exiting...")
    exit(1)
print("Token ring backup completed. saved in {}/cassandra_backup/tokenring.txt".format(tmpdir))

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

# Copying the snapshot to proper folder structure, this is not a copy but a hard link.
copy()

# Dropping unwanted keyspace schema
# Including system schemas
## deduplicating Ignore Keyspace list
ignore_keyspace_names = list(dict.fromkeys(ignore_keyspace_names))
# Creating schema for keyspaces.
create_schema("{}/cassandra_backup/snapshot_table_schema.cql".format(tmpdir))

# Clearing the snapshot.
# We've the data now available in the copied directory.
command = "nodetool clearsnapshot -t {}".format(args.snapshotname)
print("Clearing snapshot {} ...".format(args.snapshotname))
rc = system(command)
if rc != 0:
    print("Clearing snapshot {} failed".format(args.snapshotname))
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
