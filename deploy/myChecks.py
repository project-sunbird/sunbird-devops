#!/usr/bin/env python3
""" Author: S M Y ALTAMASH <smy.altamash@gmail.com> """

import os
import re
import sys
import subprocess
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError


protocol=sys.argv[1]
serverIP=sys.argv[2]
mydictionary={"MONIT":"{}://{}:2812".format(protocol,serverIP),"PROMETHEUS":"{}://{}:9090".format(protocol,serverIP),"Alertmanager":"{}://{}:9093/alertmanager".format(protocol,serverIP),"KEYCLOAK":"{}://{}/auth".format(protocol,serverIP),"SUNBIRD PORTAL":"{}://{}".format(protocol,serverIP),"GRAFANA":"{}://{}/grafana".format(protocol,serverIP)}

def checkStatus(req,name):
	try:
		response = urlopen(req)
	except HTTPError as e:
		print(str(name) + ' ' + str(" is not Working"))
	except URLError as e:
		print(str(name) + ' ' + str(' is not Working'))
	else:
		print(str(name) + ' ' + str(" is working"))

def checkAvailibility():
	for k in mydictionary:
		checkStatus(mydictionary[k],k)

def checkContainerReplication():
	print("Checking Container Replication:-\n")
	reslt=(subprocess.check_output("sudo docker service ls | grep \" 0/\" | awk '{ print $2 }'", shell=True)).splitlines()
	for val in reslt:
		print("Container "+str(val,"utf-8")+" Failed to replicate")


print("\n-----------------------------------------\n")
print("Checking The service Working Status:-\n")
checkAvailibility()
print("\n-----------------------------------------\n")

checkContainerReplication()
print("\n-----------------------------------------\n")



#print("\nThe King Never Fails To Win His Destiny\n")
