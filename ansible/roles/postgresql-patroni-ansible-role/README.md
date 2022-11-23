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
```
Architecture
------------
![Untitled Diagram (1)](https://user-images.githubusercontent.com/63706239/203470986-f8ec3d56-a6d2-4678-b594-dc20a29ec972.jpg)

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
