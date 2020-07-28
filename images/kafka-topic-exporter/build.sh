# vim: set ts=4 sw=4 tw=0 et :
#!/bin/bash

# Have to copy this file because In docker container we can't pass directories other than PWD
cp ../../exporters/Go/kafka-topic-exporter/{main.go,go.mod,go.sum} .
docker build -f Dockerfile -t sunbird/kafka-topic-exporter:v3 .
