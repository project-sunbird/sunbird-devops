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
Dependencies
------------
```
Note : Tested with Ubuntu
```
Example Playbook
----------------


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