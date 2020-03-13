FROM golang:1.13 AS builder
COPY main.go /work
WORKDIR /work
RUN CGO_ENABLED=0 go build -o kafka-topic-exporter main.go

FROM scratch
LABEL maintainer="Rajesh Rajendran<rjshrjndrn@gmail.com>"
COPY --from=bulder /work/kafka-topic-exporter /
EXPOSE 8000
CMD ["/kafka-topic-exporter"]
