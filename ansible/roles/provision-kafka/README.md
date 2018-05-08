#Kafka
Installs [kafka](https://kafka.apache.org/)

##Requirements
- kafka_hosts - comma separated list of host:port pairs in the cluster, defaults to 'ansible_fqdn:9092' for a single node 
- zookeeper_hosts - comma separated list of host:port pairs.

##Optional
- kafka_listen_address - defines a specifc address for kafka to listen on, by defaults listens on all interfaces
- kafka_id - Id to be used if one can't or shouldn't be derived from kafka_hosts. This will happen if kafka_hosts doesn't contain the fqdn but an alias
- monasca_log_level - Log level to be used for Kafka logs. Defaults to WARN
- run_mode - One of Deploy, Stop, Install, Start, or Use. The default is Deploy which will do Install, Configure, then Start. 

##License
Apache

##Author Information
Tim Kuhlman

Monasca Team email monasca@lists.launchpad.net
