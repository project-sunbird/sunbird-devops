#!/bin/bash
export HOSTNAME_IP=$(hostname -i)
echo "hostname -i returned: $HOSTNAME_IP"
echo "export POSTGRES_PASSWORD=`cat /run/secrets/postgresql_keycloak_pass`" >> ~/.bashrc
source ~/.bashrc
exec /opt/jboss/keycloak/bin/standalone.sh -Djboss.bind.address.private=$HOSTNAME_IP -Djboss.jgroups.tcpping.initial_hosts=$TCPPING_INITIAL_HOSTS $@
cd keycloak/bin
./add-user-keycloak.sh -u admin -p 3KSt3p1707
exit $?