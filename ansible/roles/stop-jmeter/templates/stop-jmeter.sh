#!/bin/bash

pid=$(ps -ef | grep jmeter | awk -F " " '{print $2}' | tr "\n" " ")
sudo kill -9 $pid
