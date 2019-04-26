#!/bin/bash

pid=$(ps -ef | grep jmeter-server | awk -F " " '{print $2}' | tr "\n" " ")
sudo kill -9 $pid