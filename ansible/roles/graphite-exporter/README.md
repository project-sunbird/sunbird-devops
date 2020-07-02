## Graphite exporter as systemd

This role will install graphite exporter as systemd process in VM for applications which emit metrics in graphite format to injest the metrics in to prometheus.

### Applications

1. Druid:
    1. Enable druid [metrics](https://github.com/apache/druid/blob/master/docs/operations/metrics.md) in `/data/druid/whitelist` 
       ref: 
    2. Add below config in `/data/druid/conf/druid/_common/common.runtime.properties`
       ```
       druid.emitter.graphite.port=9109
       druid.emitter.graphite.hostname=localhost
       druid.emitter.graphite.protocol=plaintext
       ```
    3. Add scrape config in prometheus to scrape `this_machine_ip:9108` port
