# vim: set ts=4 sw=4 tw=0 et :
#!/bin/bash

# Have to copy this file because In docker container we can't pass directories other than PWD
docker build -f Dockerfile -t sunbird/azure-ambari-prometheus-exporter:v1 .
