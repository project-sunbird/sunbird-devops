//  vim: set ts=4 sw=4 tw=0 noet :
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
	"sync"
	"time"

	kafka "github.com/rjshrjndrn/kafka-go"
)

// This is to get the last message served to prom endpoint.
type lastReadMessage struct {
	mu   sync.RWMutex
	last kafka.Message
}

// Adding message
func (lrm *lastReadMessage) Store(message kafka.Message) {
	lrm.mu.Lock()
	defer lrm.mu.Unlock()

	lrm.last = message
}

// Return the last message read
func (lrm *lastReadMessage) Get() kafka.Message {
	lrm.mu.RLock()
	defer lrm.mu.RUnlock()
	return lrm.last
}

// Message format
type metric struct {
	message string
	id      kafka.Message
}

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
func (metrics *Metrics) pushMetrics(ctx context.Context, metricData *kafka.Message) (err error) {
	label := fmt.Sprintf("system=%q,subsystem=%q,", metrics.System, metrics.SubSystem)
	select {
	case <-ctx.Done():
		return ctx.Err()
	default:
		// Creating dictionary of labels
		for _, labels := range metrics.Lables {
			// Lables can't have '-' in it
			label += fmt.Sprintf("%v=%q,", metricsNameValidator(labels.ID), labels.Value)
		}
		// Generating metrics
		for _, m := range metrics.Metrics {
			metricStruct := metric{}
			// Adding optional timestamp
			switch metrics.MetricTS {
			case "":
				metricStruct.message = fmt.Sprintf("%s{%s} %.2f", metricsNameValidator(metrics.System, metrics.SubSystem, m.ID), strings.TrimRight(label, ","), m.Value)
			default:
				metricStruct.message = fmt.Sprintf("%s{%s} %.1f %s", metricsNameValidator(metrics.System, metrics.SubSystem, m.ID), strings.TrimRight(label, ","), m.Value, metrics.MetricTS)
			}
			fmt.Printf("%s\n", metricStruct.message)
			metricStruct.id = *metricData
			promMetricsChannel <- metricStruct
		}
		return nil
	}
}

// Channel to keep metrics till prometheus scrape that
var promMetricsChannel = make(chan metric)

func metricsCreation(ctx context.Context, m kafka.Message) error {
	metrics := Metrics{}
	data := m.Value
	// Creating metrics struct
	select {
	case <-ctx.Done():
		return ctx.Err()
	default:
		if err := json.Unmarshal(data, &metrics); err != nil {
			fmt.Printf("Unmarshal error: %q\n", err)
			return err
		}
		metrics.pushMetrics(ctx, &m)
		return nil
	}
}

// Http handler
func serve(w http.ResponseWriter, r *http.Request) {
	// Channel to keep track of offset lag
	lagChannel := make(chan int64, 1)
	ctx := r.Context()
	lastReadMessage := lastReadMessage{}
	// Creating context
	// Reading topic
	go func(ctx context.Context, r *kafka.Reader) {
		for {
			// Only fetching the message, not commiting them
			// It'll be commited once the transmission closes
			m, err := r.FetchMessage(ctx)
			if err != nil {
				fmt.Printf("err reading message: %v\n", err)
				break
			}
			fmt.Printf("topic: %q partition: %v offset: %v lag: %d\n ", m.Topic, m.Partition, m.Offset, r.Lag())
			go func(ctx context.Context) {
				if err := metricsCreation(ctx, m); err != nil {
					fmt.Printf("errored out metrics creation; err:  %s\n", err)
					return
				}
			}(ctx)
			lagChannel <- r.Lag()
		}
	}(ctx, kafkaReader)
	for {
		select {
		case message := <-promMetricsChannel:
			lastReadMessage.Store(message.id)
			fmt.Fprintf(w, "%s\n", message.message)
			// Waiting for 1 ms before quitting
		case <-ctx.Done():
			// explicitly commiting last read message
			messageLastRead := lastReadMessage.Get()
			// Don't commit if offset is zero
			if messageLastRead.Offset != 0 {
				fmt.Printf("Commiting message offset %d\n", messageLastRead.Offset)
				// Using context.Background, Commit need to be successful.
				if err := kafkaReader.CommitMessages(context.Background(), messageLastRead); err != nil {
					fmt.Printf("Error commiting message, err: %q\n", err)
				}

			}
			fmt.Printf("done\n")
			return
		case lag := <-lagChannel:
			if lag == 0 {
				// explicitly commiting last read message
				messageLastRead := lastReadMessage.Get()
				// Don't commit if offset is zero
				if messageLastRead.Offset != 0 {
					// explicitly commiting last read message
					messageLastRead := lastReadMessage.Get()
					fmt.Printf("Commiting message offset %d\n", messageLastRead.Offset)
					if err := kafkaReader.CommitMessages(ctx, messageLastRead); err != nil {
						fmt.Printf("Error commiting message, err: %q\n", err)
					}
				}
				fmt.Println("queue length: ", len(promMetricsChannel))
				return
			}
		}
	}
}

var kafkaReader *kafka.Reader

func main() {
	// Getting kafka_ip and topic
	kafkaHost := os.Getenv("kafka_host")
	kafkaTopic := os.Getenv("kafka_topic")
	if kafkaTopic == "" || kafkaHost == "" {
		log.Fatalf(`"kafka_topic or kafka_host environment variables not set."
For example,
	export kafka_host=10.0.0.9:9092
	kafka_topic=sunbird.metrics.topic`)
	}
	fmt.Printf("kafak_host: %s\nkafka_topic: %s\n", kafkaHost, kafkaTopic)
	// Checking kafka port and ip are accessible
	fmt.Println("Checking connection to kafka")
	conn, err := net.DialTimeout("tcp", kafkaHost, 10*time.Second)
	if err != nil {
		log.Fatalf("Connection error: %s", err)
	}
	conn.Close()
	fmt.Println("kafka is accessible")
	// Initializing kafka
	kafkaReader = kafka.NewReader(kafka.ReaderConfig{
		Brokers:          []string{kafkaHost},
		GroupID:          "metrics-reader-test", // Consumer group ID
		Topic:            kafkaTopic,
		MinBytes:         1e3,  // 1KB
		MaxBytes:         10e6, // 10MB
		MaxWait:          200 * time.Millisecond,
		RebalanceTimeout: time.Second * 5,
	})
	defer kafkaReader.Close()
	http.HandleFunc("/metrics", serve)
	log.Fatal(http.ListenAndServe(":8000", nil))
}
