Role Name
=========

Ansible role for postgresql cluster with 1 master and 2 replicas with Patroni

Requirements
------------



Role Variables
--------------
```
#patroni .yaml config
Postgres_cluster_name: postgresql-prod      # Cluster name

# users admin password
admin_password: admin                       # Admin Password

#Authentication
# Replication
replication_username: replicator            # Replication Username
replication_password: password              # Replication password

#SuperUser
superuser_username: postgres                # Superuser username
superuser_password: password                # Superuser Password
```
Dependencies
------------



Example Playbook
----------------



License
-------

BSD

Author Information
------------------


