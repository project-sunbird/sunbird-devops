#!/bin/bash

KEYCLOAK_USER=admin
KEYCLOAK_PASSWORD=ash12345^&*()

export HOSTNAME_IP=$(hostname -i)
export HOSTNAME_IP_ALL=$(hostname --all-ip-addresses)
echo "hostname -i returned: $HOSTNAME_IP, -I returned: $HOSTNAME_IP_ALL"

exec /opt/jboss/keycloak/bin/standalone.sh -Djboss.bind.address.private=$HOSTNAME $@
exit $?

