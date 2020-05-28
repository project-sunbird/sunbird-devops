#!/usr/bin/env python3
 
import os
from subprocess import check_output, STDOUT
from re import match, DOTALL, compile
 
root_dir = '/var/lib/cassandra/data'
log_file = os.path.expanduser("~")+'/cassandra_row_count.txt'
os.chdir(root_dir)
ignore_list = compile(r'(system|system|systemtauth|system_traces|system_schema|system_distributed)')
 
with open(log_file,'a') as cf:
    for i in os.listdir(root_dir):
        if match(ignore_list, i):
            continue
        try:
            for j in os.listdir(i):
                ks = i+'.'+str(j.split('-')[0])
                val = 'cqlsh --request-timeout=36000 -e "select count(*) from {};"'.format(ks)
                try:
                    out = check_output(["/bin/bash","-c",val], stderr=STDOUT)
                except Exception as e:
                    print(e)
                    pass
                tmp = ks+' : '+match(r'.+\s(\d+).+', str(out), DOTALL).group(1)
                cf.write(tmp+'\n')
                print(tmp)
        except Exception as e:
            print(e)
