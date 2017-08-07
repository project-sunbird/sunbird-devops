#!/usr/bin/env bash
# Script to run a java application for testing jmx4prometheus.

# Note: You can use localhost:5556 instead of 5556 for configuring socket hostname.

java -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=7199 -jar /usr/share/cassandra/lib/jmx_prometheus_httpserver-0.11.jar 7199 /etc/cassandra/cassandra_jmx.yaml
