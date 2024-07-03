#!/bin/bash

set -eu -o pipefail

echo "Get the keycloak.conf template file"
curl -sS https://raw.githubusercontent.com/project-sunbird/sunbird-devops/release-7.0.0/ansible/roles/keycloak-deploy/templates/keycloak.conf --output keycloak.conf

echo "Get the current VM IP"
ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"

echo "Replace ansible variables with postgres details"
sed -i "s/{{keycloak_postgres_host}}/$PG_HOST/g" keycloak.conf
sed -i "s/{{keycloak_postgres_database}}/${PG_DB}7/g" keycloak.conf
sed -i "s/{{keycloak_postgres_user}}/$PG_USER/g" keycloak.conf
sed -i "s/{{keycloak_postgres_password}}/$PGPASSWORD/g" keycloak.conf
sed -i "s/{{ansible_default_ipv4.address}}/$ip/g" keycloak.conf
sed -i "s/8080/8081/g" keycloak.conf
sed -i "s/\"900\"/\"3600\"/g" keycloak.conf

echo "Get vanilla keycloak package"
wget -q https://github.com/keycloak/keycloak/releases/download/21.1.2/keycloak-21.1.2.tar.gz

echo "Extract keycloak package"
tar -xvzf keycloak-21.1.2.tar.gz

echo "Copy keycloak.conf file to keycloak package"
cp keycloak.conf keycloak-21.1.2/conf/

echo "Backup the existing keycloak db"
pg_dump -Fd -j 4 -h $PG_HOST -U $PG_USER -d $PG_DB -f ${PG_DB}

echo "Create a new db for keycloak 21"
psql -h $PG_HOST -U $PG_USER -p 5432 -d postgres -c "CREATE DATABASE ${PG_DB}21"

echo "Restore the existing keycloak 7 db to the new database"
pg_restore -O -j 4 -h $PG_HOST -U $PG_USER -d ${PG_DB}21 ${PG_DB}

echo "Clear the DB of duplicate values"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "delete from public.COMPOSITE_ROLE a using public.COMPOSITE_ROLE b where a=b and a.ctid < b.ctid"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "delete from public.REALM_EVENTS_LISTENERS a using public.REALM_EVENTS_LISTENERS b where a=b and a.ctid < b.ctid"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "delete from public.REDIRECT_URIS a using public.REDIRECT_URIS b where a=b and a.ctid < b.ctid"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "delete from public.WEB_ORIGINS a using public.WEB_ORIGINS b where a=b and a.ctid < b.ctid"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "truncate offline_user_session"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "truncate offline_client_session"
psql -h $PG_HOST -U $PG_USER -p 5432 -d ${PG_DB}7 -c "truncate jgroupsping" || true

echo "Migrate the DB to keycloak 21"
cd keycloak-21.1.2
bin/kc.sh start --spi-connections-jpa-legacy-migration-strategy=update -b=$ip -bprivate=$ip