FROM alpine:3.6

ARG POSTGRES_EXPORTER_VERSION=v0.2.2

RUN apk --no-cache add openssl

RUN wget -O /usr/local/bin/postgres_exporter https://github.com/wrouesnel/postgres_exporter/releases/download/$POSTGRES_EXPORTER_VERSION/postgres_exporter && \
    chmod +x /usr/local/bin/postgres_exporter

EXPOSE 9187

ENTRYPOINT ["/usr/local/bin/postgres_exporter"]