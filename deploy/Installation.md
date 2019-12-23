# This is Minimal installation of sunbird
Componants:
1. Core - all containerized services
2. DBs - all databases
3. KP - Knowledge platform

Infastructure required.
Three 2 core 8G machines

> If you don't have a ssl certificate but public domain name, you can run deploy/certbot.sh

1. Will create a single node kubernetes cluster
   - you can access via `kubectl` from the machine
   - optional you can enable rancher admin dashboard
2. Create databases on the second machine
   - Cassandra
   - Elastic Search
   - Postgres
   - Neo4j
3. Create KP services on the third
   - Learning service
   - Search service

### Installation Steps
1. Create 3vms(one of them should have a public ip, and 80,443 exposed to internet) of 2core 8Gi of ubuntu16.04
2. azure storage account with one public container( for example content)
3. Create a keyfile ~/deployer.pem which can ssh into all nodes and set `chmod 0400 ~/deployer.pem`
> Note: The user should have password less sudo access to all machines
4. clone rjshrjndrn/sunbird-devops -b 3node
5. open sunbird-devops/deploy -> ./certbot.sh # To generate certificates from Letsencrypt, should see certs in `ls ~`
6. sunbird-devops/private_repo/ansible/inventory/dev/ Core and KnowledgePlatform fill hosts, common, secrets
7. example inventory seggregation

| module | application | ip       |
|--------|-------------|----------|
| Core   | kubernetes  | 10.1.4.4 |
|        | keycloak    |          |
| DBs    | Cassandra   | 10.1.4.5 |
|        | Neo4j       |          |
|        | postgres    |          |
|        | redis       |          |
| KP     | learning    | 10.1.4.6 |
|        | search      |          |
|        | ES          |          |
|        | Kafka       |          |
8. export your inventory path `export INVENTORY_PATH=/home/ops/sunbird-devops/private_repo/ansible/dev/`
9. cd sunbird-devops/deploy && bash -x install.sh
