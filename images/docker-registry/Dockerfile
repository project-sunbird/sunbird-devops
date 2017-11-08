FROM registry:2
COPY images/docker-registry/docker-entrypoint.sh .
RUN chmod a+x docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["/etc/docker/registry/config.yml"]
