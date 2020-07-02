<<<<<<< HEAD
FROM kong:0.12.3

ENV KONG_VERSION 0.12.3

RUN yum install -y net-tools

COPY plugins/$KONG_VERSION/rate-limiting/policies/* /usr/local/share/lua/5.1/kong/plugins/rate-limiting/policies/
COPY plugins/$KONG_VERSION/jwt/* /usr/local/share/lua/5.1/kong/plugins/jwt/
=======
FROM kong:0.14.1-centos

ENV KONG_VERSION 0.14.1
>>>>>>> 8aa1bcbf6... fix: adding kong 14 files and reverting other changes

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

COPY plugins/$KONG_VERSION/rate-limiting/policies/* /usr/local/share/lua/5.1/kong/plugins/rate-limiting/policies/
COPY templates/$KONG_VERSION/nginx_kong.lua /usr/local/share/lua/5.1/kong/templates/

# ensure Kong logs go to the log pipe from our entrypoint and so to docker logging
RUN mkdir -p /usr/local/kong/logs \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/access.log \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/error.log \
    && ln -sf /tmp/logpipe /usr/local/kong/logs/admin_access.log

EXPOSE 8000 8443 8001 7946
CMD ["kong", "start"]

