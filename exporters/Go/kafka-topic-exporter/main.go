package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	kafka "github.com/segmentio/kafka-go"
)

// Metrics structure
type Metrics struct {
	System    string `json:"system"`
	SubSystem string `json:"subsystem"`
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
	label := ""
	// Creating dictionary of labels
	for _, labels := range metrics.Lables {
		label += fmt.Sprintf("%q:%q,", labels.ID, labels.Value)
	}
	// Generating metrics
	for _, metric := range metrics.Metrics {
		retMetrics := fmt.Sprintf("%s{%s} %.2f", metricsNameValidator(metrics.System, metrics.SubSystem, metric.ID), strings.TrimRight(label, ","), metric.Value)
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
func serve(w http.ResponseWriter, r *http.Request) {
	for {
		select {
		case message := <-promMetricsChannel:
			fmt.Fprintf(w, "%s\n", message)
		case <-time.After(1 * time.Second):
			fmt.Printf("done")
			return
		}
	}

}
func main() {
	// Getting kafka_ip and topic
	kafka_host := os.Getenv("kafka_host")
	kafka_topic := os.Getenv("kafka_topic")
	if kafka_topic == "" || kafka_host == "" {
		log.Fatalf("kafka_topic or kafka_host environment variables not set")
	}
	fmt.Printf("kafak_host: %s\nkafka_topic: %s\n", kafka_host, kafka_topic)

	// Initializing kafka
	r := kafka.NewReader(kafka.ReaderConfig{
		Brokers:  []string{kafka_host},
		GroupID:  "metrics-reader-test", // Consumer group ID
		Topic:    kafka_topic,
		MinBytes: 10e3, // 10KB
		MaxBytes: 10e6, // 10MB
	})
	// Reading topic
	go func() {
		for {
			m, err := r.ReadMessage(context.Background())
			if err != nil {
				fmt.Printf("err reading message: %v", err)
				break
			}
			fmt.Printf("message at topic/partition/offset %v/%v/%v: %s = %s\n", m.Topic, m.Partition, m.Offset, string(m.Key), string(m.Value))
			metricsCreation(m.Value)
		}
	}()
	// jsonFile, err := os.Open("values.json")
	// if err != nil {
	//     log.Fatalf("Error opening file: %v", err)
	// }
	// data, _ := ioutil.ReadAll(jsonFile)
	// go metricsCreation(data)
	http.HandleFunc("/metrics", serve)
	log.Fatal(http.ListenAndServe(":8000", nil))
}
