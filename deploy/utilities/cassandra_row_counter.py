#!/usr/bin/env python3
 
import os
from subprocess import run, check_output
from re import match, DOTALL
 
root_dir = '/home/ops/cassandra_backup'
log_file = os.path.expanduser("~")+'/cassandra_row_count.txt'
os.chdir(root_dir)
 
with open(log_file,'a') as cf:
    for i in os.listdir(root_dir):
        try:
            for j in os.listdir(i):
                ks = i+'.'+str(j.split('-')[0])
                val = 'cqlsh -e "select count(*) from {};"'.format(ks)
                out = check_output(["/bin/bash","-c",val])
                tmp = ks+' : '+match(r'.+\s(\d+).+', str(out), DOTALL).group(1)
                cf.write(tmp+'\n')
                print(tmp)
        except Exception as e:
            print(e)
