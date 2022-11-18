Role Name
=========

Ansible Role for etcd

Requirements
------------

Provide the varibale in defaults for etcd configuration

Role Variables
--------------
```
etcd_name: "postgres-etcd"                                                        # cluster name
etcd_initial_cluster: "{{ etcd_name }}=http://{{ etcd_ip }}:2380"                 # initial cluster
etcd_initial_cluster_state: "postgres"                                            # initial cluster state
etcd_initial_cluster_token: "etcd-cluster-postgres"                               # initial cluster token
etcd_initial_advertise_peer_urls: "http://{{ etcd_ip }}:2380"                     # initial advertise peer urls
etcd_listen_peer_urls: "http://{{ etcd_ip }}:2380"                                # listen peer urls
etcd_listen_client_urls: "http://{{ etcd_ip }}:2379,http://127.0.0.1:2379"        # listen client urls
etcd_advertise_client_urls: "http://{{ etcd_ip }}:2379"                           # advertise client urls
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


