FROM openjdk:8-jre-alpine

ENV APP_HOME=/opt/app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY /images/cassandra_jmx_exporter/jmx_prometheus_httpserver-0.11.jar jmx_prometheus_httpserver-0.11.jar
COPY /images/cassandra_jmx_exporter/logging.properties logging.properties

EXPOSE 5556

ENTRYPOINT /usr/bin/java ${JAVA_OPTS} -jar jmx_prometheus_httpserver-0.11.jar 5556 $APP_HOME/jmx_httpserver.yml

#!/usr/bin/env bash
# Script to run a java application for testing jmx4prometheus.

# Note: You can use localhost:5556 instead of 5556 for configuring socket hostname.

#java -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=5555 -jar /usr/share/cassandra/lib/jmx_prometheus_httpserver-0.11.jar 5556 /etc/cassandra/jmx_httpserver.yml
