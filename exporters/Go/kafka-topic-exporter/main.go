// Author : Kaliraja Ramasami <kaliraja.ramasamy@tarento.com>
// Author : Rajesh Rajendran <rjshrjdnrn@gmail.com>
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	kafka "github.com/segmentio/kafka-go"
)

var kafkaReader *kafka.Reader

// Channel to keep metrics till prometheus scrape that
var promMetricsChannel = make(chan metric)

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

// This is to get the last message served to prom endpoint.
type lastReadMessage struct {
	mu sync.RWMutex
	// 	 	partition message
	last map[int]kafka.Message
}

// Adding message
// Only the latest
func (lrm *lastReadMessage) Store(message kafka.Message) error {
	lrm.mu.Lock()
	defer lrm.mu.Unlock()
	// Initializing map if nil
	if lrm.last == nil {
		lrm.last = make(map[int]kafka.Message)
	}
	if _, ok := lrm.last[message.Partition]; ok {
		// Updating only if the offset is greater
		if lrm.last[message.Partition].Offset < message.Offset {
			lrm.last[message.Partition] = message
		}
		return fmt.Errorf("lower offset(%d) than the latest(%d)", message.Offset, lrm.last[message.Partition].Offset)
	} else {
		lrm.last[message.Partition] = message
	}
	return nil
}

// Return the last message read
func (lrm *lastReadMessage) Get() map[int]kafka.Message {
	lrm.mu.RLock()
	defer lrm.mu.RUnlock()
	return lrm.last
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

// Message format
type metric struct {
	message string
	id      kafka.Message
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
				metricStruct.message = fmt.Sprintf("%s{%s} %.2f",
					metricsNameValidator(metrics.System, metrics.SubSystem, m.ID),
					strings.TrimRight(label, ","), m.Value)
			default:
				metricStruct.message = fmt.Sprintf("%s{%s} %.1f %s",
					metricsNameValidator(metrics.System, metrics.SubSystem, m.ID),
					strings.TrimRight(label, ","), m.Value, metrics.MetricTS)
			}
			// fmt.Printf("%s\n", metricStruct.message)
			metricStruct.id = *metricData
			promMetricsChannel <- metricStruct
		}
		return nil
	}
}

func metricsCreation(ctx context.Context, m kafka.Message) error {
	metrics := Metrics{}
	data := m.Value
	// Creating metrics struct
	select {
	case <-ctx.Done():
		return ctx.Err()
	default:
		if err := json.Unmarshal(data, &metrics); err != nil {
			fmt.Printf("Unmarshal error: %q data: %q\n", err, string(data))
			return err
		}
		metrics.pushMetrics(ctx, &m)
		return nil
	}
}

func commitMessage(messages *map[int]kafka.Message) error {
	for k, message := range *messages {
		if message.Offset > 0 {
			fmt.Printf("Commiting message partition %d offset %d\n", k, message.Offset)
			if err := kafkaReader.CommitMessages(context.Background(), message); err != nil {
				return err
			}
		}
		return errors.New("offset is not > 0")
	}
	return nil
}

func health(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte("{\"Healthy\": true}"))
}
func serve(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Serving Request")
	ctx := r.Context()
	lastReadMessage := lastReadMessage{}
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
			fmt.Printf("topic: %q partition: %v offset: %v\n", m.Topic, m.Partition, m.Offset)
			go func(ctx context.Context) {
				if err := metricsCreation(ctx, m); err != nil {
					fmt.Printf("errored out metrics creation; err:  %s\n", err)
					return
				}
			}(ctx)
		}
	}(ctx, kafkaReader)
	for {
		select {
		case message := <-promMetricsChannel:
			fmt.Fprintf(w, "%s\n", message.message)
			lastReadMessage.Store(message.id)
		case <-ctx.Done():
			messageLastRead := lastReadMessage.Get()
			commitMessage(&messageLastRead)
			return
		case <-time.After(1 * time.Second):
			messageLastRead := lastReadMessage.Get()
			commitMessage(&messageLastRead)
			return
		}
	}
}

func main() {
	// Getting kafka_ip and topic
	kafkaHosts := strings.Split(os.Getenv("kafka_host"), ",")
	kafkaTopic := os.Getenv("kafka_topic")
	kafkaConsumerGroupName := os.Getenv("kafka_consumer_group_name")
	if kafkaConsumerGroupName == "" {
		kafkaConsumerGroupName = "prometheus-metrics-consumer"
	}
	if kafkaTopic == "" || kafkaHosts[0] == "" {
		log.Fatalf(`"kafka_topic or kafka_host environment variables not set."
For example,
	export kafka_host=10.0.0.9:9092,10.0.0.10:9092
	kafka_topic=sunbird.metrics.topic`)
	}
	fmt.Printf("kafka_host: %s\nkafka_topic: %s\nkafka_consumer_group_name: %s\n", kafkaHosts, kafkaTopic, kafkaConsumerGroupName)
	// Checking kafka port and ip are accessible
	fmt.Println("Checking connection to kafka")
	for _, host := range kafkaHosts {
		conn, err := net.DialTimeout("tcp", host, 10*time.Second)
		if err != nil {
			log.Fatalf("Connection error: %s", err)
		}
		conn.Close()
	}
	fmt.Println("kafka is accessible")
	// Initializing kafka
	kafkaReader = kafka.NewReader(kafka.ReaderConfig{
		Brokers:          kafkaHosts,
		GroupID:          kafkaConsumerGroupName, // Consumer group ID
		Topic:            kafkaTopic,
		MinBytes:         1e3,  // 1KB
		MaxBytes:         10e6, // 10MB
		MaxWait:          200 * time.Millisecond,
		RebalanceTimeout: time.Second * 5,
	})
	defer kafkaReader.Close()
	http.HandleFunc("/metrics", serve)
	http.HandleFunc("/health", health)
	log.Fatal(http.ListenAndServe(":8000", nil))
}
