Role Name
=========
```
postgresql-cluster-ansible
```
Requirements
------------
```
1. comment or uncomment the properties in templates of the roles available as per the requirement.
2. provide the variables where ever required.
```
Role Variables
--------------
```
In hosts files:
1. etcd_ip : <etcdip is to be provided for postgresql group and etcd group>
2. postgresql_origin: <same as server ip>
3. postgresql_1: <master postgres server Ip>
4. postgresql_2: <postgres replica 1 server IP>
5. postgresql_3: <postgres replica 2 server IP>


etcd Role variables:
postgres_patroni_etcd_name: "postgres-etcd"                                                        # cluster name
postgres_patroni_etcd_initial_cluster: "{{ etcd_name }}=http://{{ etcd_ip }}:2380"                 # initial cluster
postgres_patroni_etcd_initial_cluster_state: "postgres"                                            # initial cluster state
postgres_patroni_etcd_initial_cluster_token: "etcd-cluster-postgres"                               # initial cluster token
postgres_patroni_etcd_initial_advertise_peer_urls: "http://{{ etcd_ip }}:2380"                     # initial advertise peer urls
postgres_patroni_etcd_listen_peer_urls: "http://{{ etcd_ip }}:2380"                                # listen peer urls
postgres_patroni_etcd_listen_client_urls: "http://{{ etcd_ip }}:2379,http://127.0.0.1:2379"        # listen client urls
postgres_patroni_etcd_advertise_client_urls: "http://{{ etcd_ip }}:2379"                           # advertise client urls

Ansible-postgres_patroni role Variables:
#patroni .yaml config
postgres_cluster_name: postgresql-prod      # Cluster name

# users admin password
postgres_patroni_admin_password: admin                       # Admin Password

#Authentication
# Replication
postgres_patroni_replication_username: replicator            # Replication Username
postgres_patroni_replication_password: password              # Replication password

#SuperUser
postgres_patroni_superuser_username: postgres                # Superuser username
postgres_patroni_superuser_password: password                # Superuser Password
```
Architecture
------------
![Untitled Diagram (1)](https://user-images.githubusercontent.com/63706239/203470986-f8ec3d56-a6d2-4678-b594-dc20a29ec972.jpg)

```
Description:
Ansible postgres cluter role is used to setup a postgres cluster with 1 Primary and 2 replicas where we are using the patroni as HA solution for postgres cluster.Patroni can be configured to handle tasks like replication, backups and restorations.We are also using HAProxy load Balancer to route the traffic and Etcd is a fault-tolerant, distributed key-value store that is used to store the state of the Postgres cluster. Via Patroni, all of the Postgres nodes make use of etcd to keep the Postgres cluster up and running.

Users and applications can access the postgres server using Haproxy IP and Port defined in the haproxy configuration rules. 
```

Inventory hosts file as shown Below
-----------------------------------
```
[etcd]
192.168.245.129 etcd_ip=192.168.245.129 ansible_ssh_user=ubuntu

[postgresql]
192.168.245.129 postgresql_origin=192.168.245.129 postgresql_1=192.168.245.129 postgresql_2=192.168.245.130 postgresql_3=192.168.245.131 etcd_ip=192.168.245.129 ansible_ssh_user=ubuntu
<postgres_server_2> postgresql_origin=<server_ip1> postgresql_1=<server_ip2> postgresql_2=<server_ip3> postgresql_3=<server_ip4> etcd_ip=192.168.245.129 ansible_ssh_user=ubuntu
<postgres_server_3> postgresql_origin=<server_ip1> postgresql_1=<server_ip2> postgresql_2=<server_ip3> postgresql_3=<server_ip4> etcd_ip=192.168.245.129 ansible_ssh_user=ubuntu

[haproxy]
192.168.245.129 postgresql_1=192.168.245.129 postgresql_2=192.168.245.130 postgresql_3=192.168.245.131 ansible_ssh_user=ubuntu
```

License
-------
```
BSD
```
Author Information
------------------
```
Nikhil Varma

Senior DevOps Engineer
```

postgres cluster setup using ansible
-----------------------------------

```
# Command to run Ansibe-postgresql role

$ ansible-playbook -i inventory/hosts main.yaml -K --ask-pass

# Commands to run postgresql roles by using the tags and skipping the tags

$ ansible-playbook -i inventory/hosts main.yaml -K --ask-pass --tags="<tag>"
$ ansible-playbook -i inventory/hosts main.yaml -K --ask-pass --skip-tags="<tag>"
```
