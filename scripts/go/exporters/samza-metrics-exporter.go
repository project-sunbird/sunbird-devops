package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"github.com/Shopify/sarama"
	"github.com/wvanbergen/kafka/consumergroup"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

var (
	cgroup        string
	topics        []string
	zookeeperConn string
)

type metrics struct {
	job_name  string
	partition float64
	metrics   map[string]interface{}
}

var prometheusMetrics []metrics
var msg []string

func main() {

	// Creating variables from cli
	var tmp_topics string
	flag.StringVar(&cgroup, "cgroup", "metrics.read", "Consumer group for samza metrics")
	flag.StringVar(&tmp_topics, "topics", "topic1,topic2", "Topic names to read")
	flag.StringVar(&zookeeperConn, "zookeeper", "11.2.1.15", "Ip address of the zookeeper. By default port will be 2181")
	flag.Parse()
	fmt.Println(tmp_topics)
	topics = strings.Split(tmp_topics, ",")
	fmt.Println("topics:", topics)
	fmt.Println("consumergroup:", cgroup)
	fmt.Println("zookeeperIPs:", zookeeperConn)

	// setup sarama log to stdout
	sarama.Logger = log.New(os.Stdout, "", log.Ltime)
	fmt.Println(sarama.Logger)
	// prometheus.MustRegister(gauge)
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
func initConsumer() (*consumergroup.ConsumerGroup, error) {
	// consumer config
	config := consumergroup.NewConfig()
	config.Offsets.Initial = sarama.OffsetOldest
	config.Offsets.ProcessingTimeout = 10 * time.Second
	// join to consumer group
	cg, err := consumergroup.JoinConsumerGroup(cgroup, topics, []string{zookeeperConn}, config)
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
