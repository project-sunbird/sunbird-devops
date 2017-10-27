# calculate filesytem used and free percent
elasticsearch_filesystem_data_used_percent = 100 * (elasticsearch_filesystem_data_size_bytes - elasticsearch_filesystem_data_free_bytes) / elasticsearch_filesystem_data_size_bytes
elasticsearch_filesystem_data_free_percent = 100 - elasticsearch_filesystem_data_used_percent

# alert if too few nodes are running
ALERT elasticsearch_too_few_nodes_running
  IF elasticsearch_cluster_health_number_of_node < 3
  FOR 5m
  LABELS {severity="critical"}
  ANNOTATIONS {
    description="There are only {% raw %}{{$value}}{% endraw %} < 3 ElasticSearch nodes running",
    summary="ElasticSearch running on less than 3 nodes"
  }

# alert if heap usage is over 90%
ALERT elasticsearch_heap_too_high
  IF elasticsearch_jvm_memory_used_bytes{area="heap"} / elasticsearch_jvm_memory_max_bytes{area="heap"} > 0.9
  FOR 15m
  LABELS {severity="critical"}
  ANNOTATIONS {
    description="The heap usage is over 90% for 15m",
    summary="ElasticSearch node {% raw %}{{$labels.node}}{% endraw %} heap usage is high"
  }

ALERT elasticsearch_snapshot_is_too_old
  IF (time() * 1000) - elasticsearch_snapshots_latest_successful_snapshot_timestamp{job="elasticsearch-snapshots-exporter"} > {{ expected_elasticsearch_snapshot_interval_in_minutes|int * 60 * 1000 }}
  FOR 5m
  LABELS {severity="critical"}
  ANNOTATIONS {
    description="Elasticsearch snapshot is too old",
    summary="Latest elasticSearch snapshot was taken {% raw %}{{ $value / (60 * 1000) }}{% endraw %} minutes ago. Threshold is {{ expected_elasticsearch_snapshot_interval_in_minutes }} minutes"
  }
