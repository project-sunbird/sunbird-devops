# This is Minimal installation of sunbird
Componants:
1. Core - all containerized services
2. DBs - all databases
3. KP - Knowledge platform

Infastructure required.
Three 2 core 8G machines

Steps:
> If you don't have a ssl certificate but public domain name, you can run deploy/certbot.sh
1. Will create a single node kubernetes cluster
   - you can access via `kubectl` from the machine
2. Create databases on the second machine
   - Cassandra
   - Elastic Search
   - Postgres
   - Neo4j
3. Create KP services
   - Learning service
   - Search service

Installation procedure:
1. clone sunbird-devops repo
2. cd `private_repo/ansible/dev/Core/`
3. fill the common.yaml and secrets.yaml; It is adviced to copy the folder to another location, and keep it in a private repo.
4. export INVENTORY_PATH=/path/to/the/private_repo
5. cd deploy && bash install.sh


### Manual steps
1. Create 3vms(one of them should have a public ip, and 80,443 exposed to internet) of 2core 8Gi of ubuntu16.04
2. azure storage account with one public container( for example content)
3. clone rjshrjndrn/sunbird-devops -b 3node
4. clone project-sunbird/sunbird-learning-platform
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
