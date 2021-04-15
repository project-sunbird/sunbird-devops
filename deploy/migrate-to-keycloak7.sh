#!/bin/bash

set -eu -o pipefail

echo "Get the standalone-ha.xml template file and module.xml"
curl -sS https://raw.githubusercontent.com/project-sunbird/sunbird-devops/keycloak7/ansible/roles/keycloak-deploy/templates/standalone-ha.xml --output standalone-ha.xml
curl -sS https://raw.githubusercontent.com/project-sunbird/sunbird-devops/keycloak7/ansible/roles/keycloak-deploy/templates/module.xml.j2 --output module.xml

echo "Get the current VM IP"
ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"

echo "Replace ansible variables with postgres details"
sed -i "s/{{keycloak_postgres_host}}/$PG_HOST/g" standalone-ha.xml
sed -i "s/{{keycloak_postgres_database}}/${PG_DB}7/g" standalone-ha.xml
sed -i "s/{{keycloak_postgres_user}}/$PG_USER/g" standalone-ha.xml
sed -i "s/{{keycloak_postgres_password}}/$PGPASSWORD/g" standalone-ha.xml
sed -i "s/{{ansible_default_ipv4.address}}/$ip/g" standalone-ha.xml
sed -i "s/8080/8081/g" standalone-ha.xml
sed -i "s/\"900\"/\"3600\"/g" standalone-ha.xml

echo "Get vanilla keycloak package"
wget -q https://downloads.jboss.org/keycloak/7.0.1/keycloak-7.0.1.tar.gz

echo "Extract keycloak package"
tar -xf keycloak-7.0.1.tar.gz

echo "Get the postgres jar"
wget -q https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar

echo "Copy standalone-ha.xml, postgres jar and module.xml file to keycloak package"
cp standalone-ha.xml keycloak-7.0.1/standalone/configuration
mkdir -p keycloak-7.0.1/modules/system/layers/keycloak/org/postgresql/main
cp postgresql-9.4.1212.jar keycloak-7.0.1/modules/system/layers/keycloak/org/postgresql/main
cp module.xml  keycloak-7.0.1/modules/system/layers/keycloak/org/postgresql/main

echo "Backup the existing keycloak db"
pg_dump -Fd -j 4 -h $PG_HOST -U $PG_USER -d $PG_DB -f ${PG_DB}

echo "Create a new db for keycloak 7"
psql -h $PG_HOST -U $PG_USER -p 5432 -d postgres -c "CREATE DATABASE ${PG_DB}7"

echo "Restore the existing keycloak 3 db to the new database"
pg_restore -O -j 4 -h $PG_HOST -U $PG_USER -d ${PG_DB}7 ${PG_DB}

echo "Clear the DB of duplicate values"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "delete from public.COMPOSITE_ROLE a using public.COMPOSITE_ROLE b where a=b and a.ctid < b.ctid"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "delete from public.REALM_EVENTS_LISTENERS a using public.REALM_EVENTS_LISTENERS b where a=b and a.ctid < b.ctid"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "delete from public.REDIRECT_URIS a using public.REDIRECT_URIS b where a=b and a.ctid < b.ctid"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "delete from public.WEB_ORIGINS a using public.WEB_ORIGINS b where a=b and a.ctid < b.ctid"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "truncate offline_user_session"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "truncate offline_client_session"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "truncate jgroupsping" || true

echo "Migrate the DB to keycloak 7"
cd keycloak-7.0.1
bin/standalone.sh -b=$ip -bprivate=$ip --server-config standalone-ha.xml
