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
	_ "github.com/segmentio/kafka-go/snappy"
)

var kafkaReaders []*kafka.Reader

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
	// 	 map[partition]message
	last map[int]kafka.Message
	// slice pointer of kafkaReaders
	clusterId int
}

// Adding message
// Only the latest
func (lrm *lastReadMessage) Store(message kafka.Message, clusterId int) error {
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
			lrm.clusterId = clusterId
		}
		return fmt.Errorf("lower offset(%d) than the latest(%d)", message.Offset, lrm.last[message.Partition].Offset)
	} else {
		lrm.last[message.Partition] = message
		lrm.clusterId = clusterId
	}
	return nil
}

// Return the last message read
func (lrm *lastReadMessage) Get() (map[int]kafka.Message, int) {
	lrm.mu.RLock()
	defer lrm.mu.RUnlock()
	return lrm.last, lrm.clusterId
}

// Validating metrics name
// Input a list of string, and concatinate with _ after
// Removing all - in the provided names
// Convert mix cases to lowercases
func metricsNameValidator(names ...string) string {
	retName := ""
	for _, name := range names {
		retName += strings.ReplaceAll(name, "-", "_") + "_"
	}
	return strings.ToLower(strings.TrimRight(retName, "_"))
}

// Message format
type metric struct {
	message   string
	id        kafka.Message
	clusterId int
}

// This function will take the metrics input and create prometheus metrics
// output and send it to metrics channel
// So that http endpoint can serve the data
func (metrics *Metrics) pushMetrics(clusterId int, ctx context.Context, metricData *kafka.Message) (err error) {
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
			metricStruct.id = *metricData
			metricStruct.clusterId = clusterId
			promMetricsChannel <- metricStruct
		}
		return nil
	}
}

func metricsCreation(clusterId int, ctx context.Context, m kafka.Message) error {
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
		metrics.pushMetrics(clusterId, ctx, &m)
		return nil
	}
}

func commitMessage(lastReadMessages *[]*lastReadMessage) error {
	fmt.Println("number of clusters: ", len(*lastReadMessages))
	for _, lrm := range *lastReadMessages {
		messages, clusterId := lrm.Get()
		fmt.Println("cluster: ", clusterId)
		for k, message := range messages {
			if message.Offset <= 0 {
				fmt.Println("Not committing anything", clusterId)
				return errors.New("offset is not > 0 for cluster " + string(clusterId))
			}
			fmt.Printf("Commiting message partition %d offset %d cluster %d\n", k, message.Offset, clusterId)
			if err := kafkaReaders[clusterId].CommitMessages(context.Background(), message); err != nil {
				return err
			}
		}
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
	var lastReadMessages []*lastReadMessage
	// Reading topic
	for k, v := range kafkaReaders {
		lastReadMessage := lastReadMessage{}
		lastReadMessages = append(lastReadMessages, &lastReadMessage)
		go func(clusterId int, ctx context.Context, r *kafka.Reader) {
			for {
				// Only fetching the message, not commiting them
				// It'll be commited once the transmission closes
				m, err := r.FetchMessage(ctx)
				if err != nil {
					fmt.Printf("err reading message: %v\n", err)
					break
				}
				fmt.Printf("topic: %q partition: %v offset: %v\n", m.Topic, m.Partition, m.Offset)
				go func(clusterId int, ctx context.Context, m kafka.Message) {
					if err := metricsCreation(clusterId, ctx, m); err != nil {
						fmt.Printf("errored out metrics creation; err:  %s\n", err)
						return
					}
				}(clusterId, ctx, m)
			}
		}(k, ctx, v)
	}
	for {
		select {
		case message := <-promMetricsChannel:
			fmt.Fprintf(w, "%s\n", message.message)
			lastReadMessages[message.clusterId].Store(message.id, message.clusterId)
		case <-ctx.Done():
			commitMessage(&lastReadMessages)
			return
		case <-time.After(1 * time.Second):
			commitMessage(&lastReadMessages)
			return
		}
	}
}

func main() {
	// Getting kafka_ip and topic
	kafkaHosts := strings.Split(os.Getenv("kafka_host"), ";")
	kafkaTopic := strings.Split(os.Getenv("kafka_topic"), ";")
	kafkaConsumerGroupName := os.Getenv("kafka_consumer_group_name")
	if kafkaConsumerGroupName == "" {
		kafkaConsumerGroupName = "prometheus-metrics-consumer"
	}
	if kafkaTopic[0] == "" || kafkaHosts[0] == "" {
		log.Fatalf(`"kafka_topic or kafka_host environment variables not set."
For example,
	# export kafka_host=cluster1ip1:9092,cluster1ip2:9092;cluster2ip1:9092,cluster2ip2:9092
	# export kafka_topic=cluster1topic;cluster2topic
	# ',' seperated multiple kafka nodes in the cluster and 
	# ';' seperated multiple kafka clusters
	export kafka_host=10.0.0.9:9092,10.0.0.10:9092;20.0.0.9:9092,20.0.0.10:9092
	export kafka_topic=sunbird.metrics.topic;myapp.metrics.topic`)
	}
	fmt.Printf("kafka_host: %s\nkafka_topic: %s\nkafka_consumer_group_name: %s\n", kafkaHosts, kafkaTopic, kafkaConsumerGroupName)
	// Checking kafka topics are given for all kafka clusters
	if len(kafkaHosts) != len(kafkaTopic) {
		log.Fatal("You should give same number of kafka_topics as kafka_clusters")
	}
	// Checking kafka port and ip are accessible
	fmt.Println("Checking connection to kafka")
	for _, hosts := range kafkaHosts {
		for _, host := range strings.Split(hosts, ",") {
			conn, err := net.DialTimeout("tcp", host, 10*time.Second)
			if err != nil {
				log.Fatalf("Connection error: %s", err)
			}
			fmt.Println("connection succeeded", host)
			conn.Close()
		}
	}
	fmt.Println("kafka is accessible")
	// Initializing kafka
	for k, v := range kafkaHosts {
		kafkaReaders = append(kafkaReaders, kafka.NewReader(kafka.ReaderConfig{
			Brokers:          strings.Split(v, ","),
			GroupID:          kafkaConsumerGroupName, // Consumer group ID
			Topic:            kafkaTopic[k],
			MinBytes:         1e3,  // 1KB
			MaxBytes:         10e6, // 10MB
			MaxWait:          200 * time.Millisecond,
			RebalanceTimeout: time.Second * 5,
		}))
		defer kafkaReaders[k].Close()
	}
	http.HandleFunc("/metrics", serve)
	http.HandleFunc("/health", health)
	log.Fatal(http.ListenAndServe(":8000", nil))
}
