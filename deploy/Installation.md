# This is Minimal installation of sunbird

Sunbird is a searchable, discoverable repository of resources contributed by educators, engineers, pedagogues, teachers, learning scientists, data scientists and many others. Search the repository using keywords, look through the cards or browse the resource and collaborator lists to discover resources that help save time, money and effort.

This is a mininal installation of sunbird with 3 2vCpus and 8GB RAM machines.
If you want to skip past to installation, feel free to do so.
Complete documentation can be found at [docs.sunbird.org](http://docs.sunbird.org)


## Design
<details>
<summary>Click to expand!</summary>  
  
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
</details>

## Installation

<details>
<summary>Click to expand!</summary>  

### Installation Steps
1. Create 3vms(**Core VM should have a public ip, and 80,443,8443 exposed to internet**) of 2core 8Gi of ubuntu16.04
2. Azure storage account with one public container( for example content)
3. ssh into Core VM and do the following steps
4. Create a keyfile ~/deployer.pem which can ssh into all nodes.
> Note: The user should have password less sudo access to all machines
4. `git clone https://github.com/rjshrjndrn/sunbird-devops -b 3node`
5. Open `sunbird-devops/deploy/3node.vars` and fill the variables
> It is advised to run the installation script in tmux session, as if the network is bad, installation may get interrupted.
For starting a tmux session, `tmux` and once the installation starts `ctrl+b then d` will detach the session.  
You can attach the session back with `tmux a`
6. cd sunbird-devops/deploy && bash -x install.sh
 
**example inventory seggregation**

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
</details>

## Troubleshoot wiki
[Troubleshoot wiki](3node.troubleshoot.md)
