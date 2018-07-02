FROM logstash:5.6

ENTRYPOINT ["/usr/share/logstash/bin/logstash","--pipeline.batch.size","1","-f","/etc/telemetry-logstash.conf"]
