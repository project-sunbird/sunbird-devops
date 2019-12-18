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
