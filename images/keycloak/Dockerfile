FROM jboss/keycloak-postgres:latest
RUN rm  /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml
RUN rm /opt/jboss/docker-entrypoint.sh
COPY ./images/keycloak/docker-entrypoint.sh /opt/jboss/
COPY ./images/keycloak/standalone-ha.xml  /opt/jboss/keycloak/standalone/configuration/
CMD ["-b", "0.0.0.0", "--server-config", "standalone-ha.xml"]