// This package reads the topic from kafka and prase it as prometheus metrics with optional timestamp.
// Json format should be as described below.
// {
// 	"system": "<category of the metrics, for example: samza>",
// 	"subsystem": "<producer of the metrics, for example: pipeline-metrics>",
// 	"metricts": "< timestamp of the merics, which should be passed to prometheus. This should be in epoch milliseconds>", // This is an optional field
// 	"metrics": [
// 		{
// 			"id": "<name of the metric>", // It can contain alphabets and '-' and '_'. Should should start with alphabet
// 			"value": "< value of the metric>" // Should be of int or float64
// 		}
// 		{
// 			...
// 			...
// 			...
// 		}
// 	],
// 	"dimensions": [ // Labels which will get injectd to each of the above metrics
// 		{
// 			"id": "< name of the label>", // It can contain alphabets and '-' and '_'. Should should start with alphabet
// 			"value": < value of the label>"
// 		}
// 		{
// 			...
// 			...
// 			...
// 		}
// 	]
// }
//
// Example:
// {
//     "system": "samza",
//     "subsystem": "pipeline-metrics",
//     "metricts" : 1582521646464,
//     "metrics": [
//         {
//             "id": "success-message-count",
//             "value": 1
//         },
//         {
//             "id": "skipped-message-count",
//             "value": 1
//         },
//         {
//         }
//     ],
//     "dimensions": [
//         {
//             "id": "job-name",
//             "value": "test-job"
//         },
//         {
//             "id": "partition",
//             "value": 0
//         }
//     ]
// }
//
// kafka_host and kafka_topic environment variables should be set
//
// Example:
// export kafka_host=10.0.0.9:9092
// export kafka_topic=sunbird.metrics.topic
//
// Author : Kaliraja Ramasami <kaliraja.ramasamy@tarento.com>
// Author : Rajesh Rajendran <rjshrjdnrn@gmail.com>
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
	"time"

	kafka "github.com/segmentio/kafka-go"
)

// Metrics structure
type Metrics struct {
	System    string      `json:"system"`
	SubSystem string      `json:"subsystem"`
	MetricTS  json.Number `json:"metricTs"`
	Metrics   []struct {
		ID    string  `json:"id"`
		Value float64 `json:"value"`
	} `json:"metrics"`
	// Labels to be added for the metric
	Lables []struct {
		ID string `json:"id"`
		// Even nimbers will be read as string
		Value json.Number `json:"value"`
	} `json:"dimensions"`
}

// Validating metrics name
// Input a list of string, and concatinate with _ after
// removing all - in the provided names
func metricsNameValidator(names ...string) string {
	retName := ""
	for _, name := range names {
		retName += strings.ReplaceAll(name, "-", "_") + "_"
	}
	return strings.TrimRight(retName, "_")
}

// This function will take the metrics input and create prometheus metrics
// output and send it to metrics channel
// So that http endpoint can serve the data
func (metrics *Metrics) pushMetrics() (err error) {
	label := fmt.Sprintf("system=%q,subsystem=%q,", metrics.System, metrics.SubSystem)
	// Creating dictionary of labels
	for _, labels := range metrics.Lables {
		// Lables can't have '-' in it
		label += fmt.Sprintf("%v=%q,", metricsNameValidator(labels.ID), labels.Value)
	}
	// Generating metrics
	for _, metric := range metrics.Metrics {
		retMetrics := ""
		// Adding optional timestamp
		switch metrics.MetricTS {
		case "":
			retMetrics = fmt.Sprintf("%s{%s} %.2f", metricsNameValidator(metrics.System, metrics.SubSystem, metric.ID), strings.TrimRight(label, ","), metric.Value)
		default:
			retMetrics = fmt.Sprintf("%s{%s} %.2f %s", metricsNameValidator(metrics.System, metrics.SubSystem, metric.ID), strings.TrimRight(label, ","), metric.Value, metrics.MetricTS)
		}
		fmt.Printf("%s\n", retMetrics)
		promMetricsChannel <- retMetrics
	}
	return nil
}

// Channel to keep metrics till prometheus scrape that
var promMetricsChannel = make(chan string)

func metricsCreation(data []byte) error {
	metrics := Metrics{}
	// Creating metrics struct
	if err := json.Unmarshal(data, &metrics); err != nil {
		fmt.Printf("Unmarshal error: %q\n", err)
		return err
	}
	metrics.pushMetrics()
	return nil
}

// Http handler
func serve(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	// Creating context
	// Reading topic
	go func(ctx context.Context, r *kafka.Reader) {
		for {
			m, err := r.ReadMessage(ctx)
			if err != nil {
				fmt.Printf("err reading message: %v", err)
				break
			}
			fmt.Printf("topic: %q partition: %v offset %v\n", m.Topic, m.Partition, m.Offset)
			go metricsCreation(m.Value)
		}
	}(ctx, kafkaReader)
	for {
		select {
		case message := <-promMetricsChannel:
			fmt.Fprintf(w, "%s\n", message)
			// Waiting for 1 ms before quitting
		case <-ctx.Done():
			fmt.Printf("done")
			return
		}
	}
}

var kafkaReader *kafka.Reader

func main() {
	// Getting kafka_ip and topic
	kafka_host := os.Getenv("kafka_host")
	kafka_topic := os.Getenv("kafka_topic")
	if kafka_topic == "" || kafka_host == "" {
		log.Fatalf(`"kafka_topic or kafka_host environment variables not set."
For example,
	export kafka_host=10.0.0.9:9092
	kafka_topic=sunbird.metrics.topic`)
	}
	fmt.Printf("kafak_host: %s\nkafka_topic: %s\n", kafka_host, kafka_topic)
	// Checking kafka port and ip are accessible
	fmt.Println("Checking connection to kafka")
	conn, err := net.DialTimeout("tcp", kafka_host, 10*time.Second)
	if err != nil {
		log.Fatalf("Connection error: %s", err)
	}
	conn.Close()
	fmt.Println("kafka is accessible")
	// Initializing kafka
	kafkaReader = kafka.NewReader(kafka.ReaderConfig{
		Brokers:  []string{kafka_host},
		GroupID:  "metrics-reader-test", // Consumer group ID
		Topic:    kafka_topic,
		MinBytes: 10e3, // 10KB
		MaxBytes: 10e6, // 10MB
	})
	http.HandleFunc("/metrics", serve)
	log.Fatal(http.ListenAndServe(":8000", nil))
}
