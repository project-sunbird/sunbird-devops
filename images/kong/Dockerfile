FROM centos:6

ENV KONG_VERSION 0.10.4

RUN yum update -y

RUN yum install -y wget https://sunbirdpublic.blob.core.windows.net/installation/kong-$KONG_VERSION.el6.noarch.rpm

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && chmod +x /usr/local/bin/dumb-init

RUN yum install -y net-tools

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

# ensure Kong logs go to the log pipe from our entrypoint and so to docker logging
RUN mkdir -p /usr/local/kong/logs \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/access.log \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/serf.log \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/error.log

EXPOSE 8000 8443 8001 7946
CMD ["kong", "start"]
