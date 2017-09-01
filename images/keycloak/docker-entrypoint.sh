#!/bin/bash

export HOSTNAME_IP=$(hostname -i)
echo "hostname -i returned: $HOSTNAME_IP"

exec /opt/jboss/keycloak/bin/standalone.sh -Djboss.bind.address.private=$HOSTNAME_IP -Djboss.jgroups.tcpping.initial_hosts=$TCPPING_INITIAL_HOSTS $@
exit $?