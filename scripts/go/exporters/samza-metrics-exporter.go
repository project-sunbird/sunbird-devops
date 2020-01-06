package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/Shopify/sarama"
	"github.com/wvanbergen/kafka/consumergroup"
)

const (
	zookeeperConn = "11.2.1.15:2181"
	cgroup        = "metrics.read"
	topic1        = "sunbirddev.analytics_metrics"
	topic2        = "sunbirddev.pipeline_metrics"
)

type metrics struct {
	job_name  string
	partition float64
	metrics   map[string]interface{}
}

var prometheusMetrics []metrics
var msg []string

func main() {
	// setup sarama log to stdout
	sarama.Logger = log.New(os.Stdout, "", log.Ltime)
	fmt.Println(sarama.Logger)
	http.HandleFunc("/metrics", serve)
	// init consumer
	cg, err := initConsumer()
	if err != nil {
		fmt.Println("Error consumer goup: ", err.Error())
		os.Exit(1)
	}
	defer cg.Close()
	// run consumer
	go consume(cg)
	log.Fatal(http.ListenAndServe(":8000", nil))
}

// Serve function
func serve(w http.ResponseWriter, r *http.Request) {
	for _, value := range prometheusMetrics {
		// fmt.Println(value.metrics)
		for k, j := range value.metrics {
			fmt.Fprintf(w, "samza_metrics_%v{job_name=\"%v\",partition=\"%v\"} %v\n", strings.ReplaceAll(k, "-", "_"), value.job_name, value.partition, j)
			fmt.Printf("samza_metrics_%v{job_name=\"%v\",partition=\"%v\"} %v\n", strings.ReplaceAll(k, "-", "_"), value.job_name, value.partition, j)
		}
	}
	prometheusMetrics = nil
}

// Initialize the consumer and subscribe
func initConsumer() (*consumergroup.ConsumerGroup, error) {
	// consumer config
	config := consumergroup.NewConfig()
	config.Offsets.Initial = sarama.OffsetOldest
	config.Offsets.ProcessingTimeout = 10 * time.Second
	// join to consumer group
	cg, err := consumergroup.JoinConsumerGroup(cgroup, []string{topic1, topic2}, []string{zookeeperConn}, config)
	if err != nil {
		return nil, err
	}
	return cg, err
}

// Metrics value should be of value type float64
// else drop the value
func metricsValidator(m map[string]interface{}) map[string]interface{} {
	for key, val := range m {
		switch v, ok := val.(float64); ok {
		// converting interface to float64
		case true:
			m[key] = v
		// Dropping not float64 values
		default:
			fmt.Println("Dropping not float64 value", key, val)
			delete(m, key)
		}
	}
	return m
}

// Convert the message to prometheus data structure
func convertor(jsons []byte) {
	var m map[string]interface{}
	err := json.Unmarshal(jsons, &m)
	if err != nil {
		panic(err)
	}
	job_name, _ := m["job-name"].(string)
	partition, _ := m["partition"].(float64)
	delete(m, "metricts")
	delete(m, "job-name")
	delete(m, "partition")
	prometheusMetrics = append(prometheusMetrics, metrics{job_name, partition, metricsValidator(m)})
}

/*
metrics reference
samza_metrics_asset_enrichment {"partition": 1, "consumer-lag" : 2, "failed_message_count": 2}
*/
// Consuming the message
func consume(cg *consumergroup.ConsumerGroup) {
	for {
		select {
		case message := <-cg.Messages():
			convertor(message.Value)
			err := cg.CommitUpto(message)
			if err != nil {
				fmt.Println("Error commit zookeeper: ", err.Error())
			}
		}
	}
}
