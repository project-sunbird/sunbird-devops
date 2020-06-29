FROM kong:0.15.0

ENV KONG_VERSION 0.15.0

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

COPY plugins/$KONG_VERSION/rate-limiting/policies/* /usr/local/share/lua/5.1/kong/plugins/rate-limiting/policies/

# ensure Kong logs go to the log pipe from our entrypoint and so to docker logging
RUN mkdir -p /usr/local/kong/logs \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/access.log \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/serf.log \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/error.log \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/admin_access.log

EXPOSE 8000 8443 8001 7946
CMD ["kong", "start"]

