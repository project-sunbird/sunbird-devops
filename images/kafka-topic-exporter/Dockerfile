FROM golang:1.13.10 AS builder
WORKDIR /work
COPY main.go /work
RUN go get github.com/segmentio/kafka-go ; go get github.com/segmentio/kafka-go/snappy
RUN CGO_ENABLED=0 go build -o kafka-topic-exporter main.go

FROM scratch
LABEL maintainer="Rajesh Rajendran<rjshrjndrn@gmail.com>"
COPY --from=builder /work/kafka-topic-exporter /
EXPOSE 8000
CMD ["/kafka-topic-exporter"]
