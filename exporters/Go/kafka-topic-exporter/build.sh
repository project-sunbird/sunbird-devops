# vim: set ts=4 sw=4 tw=0 et :
#!/bin/bash

CGO_ENABLED=0 go build -o kafka-topic-exporter main.go
docker build -f Dockerfile -t sunbird/kafka-topic-exporter:v1 .
