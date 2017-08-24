FROM jboss/keycloak-postgres:latest

RUN rm /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml
COPY standalone-ha.xml  /opt/jboss/keycloak/standalone/configuration/
COPY postgresql-9.4.1212.jar /opt/jboss/keycloak/modules/system/layers/keycloak/org/postgresql/main/
COPY module.xml /opt/jboss/keycloak/modules/system/layers/keycloak/org/postgresql/main/
COPY docker-entrypoint.sh /opt/jboss/

ENTRYPOINT ["/opt/jboss/docker-entrypoint.sh"]

CMD ["-b", "0.0.0.0", "--server-config", "standalone-ha.xml"]