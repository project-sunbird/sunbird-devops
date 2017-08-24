FROM jboss/keycloak-postgres:latest

RUN rm /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml
COPY ./images/keycloak/standalone-ha.xml  /opt/jboss/keycloak/standalone/configuration/
COPY ./images/keycloak/postgresql-9.4.1212.jar /opt/jboss/keycloak/modules/system/layers/keycloak/org/postgresql/main/
COPY ./images/keycloak/module.xml /opt/jboss/keycloak/modules/system/layers/keycloak/org/postgresql/main/
COPY ./images/keycloak/docker-entrypoint.sh /opt/jboss/

ENTRYPOINT ["/opt/jboss/docker-entrypoint.sh"]

CMD ["-b", "0.0.0.0", "--server-config", "standalone-ha.xml"]