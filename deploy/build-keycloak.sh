#!/bin/sh
wget https://downloads.jboss.org/keycloak/3.2.0.Final/keycloak-3.2.0.Final.tar.gz
tar -xvf keycloak-3.2.0.Final.tar.gz
mv keycloak-3.2.0.Final keycloak
tar -czvf keycloak.tar.gz  keycloak
mv keycloak.tar.gz $1