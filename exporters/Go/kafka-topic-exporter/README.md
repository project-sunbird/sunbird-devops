## Design

This program is designed to be eventually consistent, metrics exporter.

## What it does

Scrape a kafka topic for metrics of specific json format, and expose one endpoint for prometheus

## How to run

`docker run -e kafaka_host=11.1.1.11:9092 -e kafka_topic=metrics.topic.dev rjshrjndrn/kafka-topic-exporter:v1`

## Json format

```
{
	"system": "<category of the metrics, for example: samza>",
	"subsystem": "<producer of the metrics, for example: pipeline-metrics>",
	"metricts": "< timestamp of the merics, which should be passed to prometheus. This should be in epoch milliseconds>", // This is an optional field
	"metrics": [
		{
			"id": "<name of the metric>", // It can contain alphabets and '-' and '_'. Should should start with alphabet
			"value": "< value of the metric>" // Should be of int or float64
		}
		{
			...
			...
			...
		}
	],
	"dimensions": [ // Labels which will get injectd to each of the above metrics
		{
			"id": "< name of the label>", // It can contain alphabets and '-' and '_'. Should should start with alphabet
			"value": < value of the label>"
		}
		{
			...
			...
			...
		}
	]
}
```
                                                                                                                                                    
Example:
```
{
    "system": "samza",
    "subsystem": "pipeline-metrics",
    "metricts" : 1582521646464,
    "metrics": [
        {
            "id": "success-message-count",
            "value": 1
        },
        {
            "id": "skipped-message-count",
            "value": 1
        },
        {
        }
    ],
    "dimensions": [
        {
            "id": "job-name",
            "value": "test-job"
        },
        {
            "id": "partition",
            "value": 0
        }
    ]
}
```
