# This is Minimal opinionated installation of sunbird

Sunbird is a searchable, discoverable repository of resources contributed by educators, engineers, pedagogues, teachers, learning scientists, data scientists and many others. Search the repository using keywords, look through the cards or browse the resource and collaborator lists to discover resources that help save time, money and effort.

This is a minimal installation of sunbird with 3 2vCpus and 8GB RAM 50G(HardDisk) VMs Ubuntu16.04.  
Full fledged installation documentation can be found at [docs.sunbird.org](http://docs.sunbird.org)  


## Design choices made for 3node installation
<details>
<summary>Click to expand!</summary>  
  
#### Sunbird Componants:

1. Core - all containerized services
2. DBs - all databases
3. KP - Knowledge platform

#### Infrastructure required.

Three 2vCpus 8GB(RAM) VMs 50G(HardDisk)

#### What's happening in the script

1. Create a single node kubernetes cluster
   - you can access via `kubectl` from the VM
   - optional you can enable rancher admin dashboard
2. Create databases on the second VM
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
1. Create 3vms(**Core VM should have a public ip, and 80,443,8443 exposed to internet**) of 2core(CPU) 8GB(RAM) 50GB(HardDisk) of Ubuntu16.04
2. Create Azure storage account with one public container named `content`
3. ssh into Core VM and do the following steps
    > Note: The user should have password less sudo access to all VMs
    1. Create a key file `vim ~/deployer.pem` which can ssh into all nodes.
    2. `git clone https://github.com/project-sunbird/sunbird-devops -b 3node`
    3. Open `sunbird-devops/deploy/3node.vars` and update the variables
    > It is advised to run the installation script in tmux session, as if the network is bad, installation may get interrupted.
    For starting a tmux session, `tmux` and once the installation starts `ctrl+b then d` will detach the session.  
    You can attach the session back with `tmux a`
    4. cd sunbird-devops/deploy && bash -x install.sh | tee -a ~/sunbird.log
 
**example inventory segregation**

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
