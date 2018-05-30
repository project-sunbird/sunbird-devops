#!/usr/bin/python3
# Author S M Y ALTAMASH <smy.altamash@gmail.com>
import sys
import subprocess
import multiprocessing
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
import csv

protocol=sys.argv[1]
serverIP=sys.argv[2]

def checkStatus(req,name):
        try:
                response = urlopen(req)
                print(str(name) + ' ' + str(" is working"))
                #print("HTTP Header:\n" .join(str(response.headers).split("\n")[:-1]))
                print("HTTP Header:")
                print(str(response.headers).rsplit("\n", 2)[0])
                print("HTTP Response Status code: "+str(response.status))
               # print(response.info())
        except HTTPError as e:
                print('The server couldn\'t fulfill the request.')
                print('Error code: ', e.code)
        except URLError as e:
                print('We failed to reach a server.')
                print('Reason: ', e.reason)

def checkAvailibility():
        with open("ServiceDetails.csv","r") as k:
                reading=csv.reader(k)
                for data in reading:
                        try:
                                ServiceName,Port,AdditionalURL=data
                                if ServiceName == "ServiceName" and Port == "Port" and AdditionalURL == "AdditionalURL":
                                        continue
                                name=ServiceName
                                print("\n\nService name: " +str(name))
                                if Port == "":
                                        req="{}://{}{}".format(protocol,serverIP,AdditionalURL)
                                else:
                                        req="{}://{}:{}{}".format(protocol,serverIP,Port,AdditionalURL)

                                p = multiprocessing.Process(target=checkStatus(req,name))
                                p.start()
                                p.join(5)
                                if p.is_alive():
                                        print(str(k) + ' ' + str(' is not Working'))
                                        p.terminate()
                                        p.join(5)                                
                        except Exception as e:
                                continue

def checkContainerReplication():
        print("Checking Container Replication:-\n")
        reslt=(subprocess.check_output("sudo docker service ls | awk 'NR>1{print $2,$4 }' | sed 's/\// /g'| awk '($2!=$3) || (($2==0) && ($3==0)){ print $1}'", shell=True)).splitlines()
        for val in reslt:
                print("Container "+str(val,"utf-8")+" Failed to replicate")

print("\n-----------------------------------------\n")
checkContainerReplication()
print("\n-----------------------------------------\n")
print("Checking The service status:-\n")
checkAvailibility()
print("\n-----------------------------------------\n")
