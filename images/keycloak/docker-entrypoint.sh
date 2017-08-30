#!/bin/bash
export HOSTNAME_IP=$(hostname -i)
echo "hostname -i returned: $HOSTNAME_IP"
echo "export TCPPING_INITIAL_HOSTS=`cat /run/secrets/postgresql_keycloak_pass`" >> ~/.bashrc
source ~/.bashrc
exec /opt/jboss/keycloak/bin/standalone.sh -Djboss.bind.address.private=$HOSTNAME_IP -Djboss.jgroups.tcpping.initial_hosts=$TCPPING_INITIAL_HOSTS $@
exit $?