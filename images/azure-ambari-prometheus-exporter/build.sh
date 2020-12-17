#!/bin/bash

build_tag=$1
node=$2
org=$3

docker build -f Dockerfile -t ${org}/azure-ambari-prometheus-exporter:${build_tag} .
echo {\"image_name\" : \"azure-ambari-prometheus-exporter\", \"image_tag\" : \"${build_tag}\", \"node_name\" : \"$node\"} > metadata.json
