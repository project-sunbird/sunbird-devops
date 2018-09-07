#!/usr/bin/env python3
 
import os
from subprocess import run, check_output
from re import match, DOTALL
 
root_dir = '/home/ops/cassandra_backup'
 
for i in os.listdir(root_dir):
    try:
        for j in os.listdir(i):
            ks = i+'.'+str(j.split('-')[0])
            val = 'cqlsh -e "select count(*) from {};"'.format(ks)
            out = check_output(["/bin/bash","-c",val])
            print(ks+' : '+match(r'.+\s(\d+).+', str(out), DOTALL).group(1))
    except NotADirectoryError as e:
        print(e)
